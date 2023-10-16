global without sharing class Talent_Management_Sharing implements Database.Batchable<sObject> {
//
// Email address from the person who launched the Batch
// used for sending all messages (Exceptions, End of Batch, etc.)
// 
	final private String myEmailAddress;
//
// Constructor: Store the email address
// 
    public Talent_Management_Sharing() {
        myEmailAddress = UserInfo.getUserEmail();
    }
//
//
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String query = 'SELECT Id, User__r.IsActive, ' +
            		   'User__r.Mgmt_Chain_Hierarchy_Level_02__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_03__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_04__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_05__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_06__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_07__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_08__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_09__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_10__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_11__c, ' +
                       'User__r.Mgmt_Chain_Hierarchy_Level_12__c ' +
                       'FROM Talent_Management__c';
//        if( Test.isRunningTest() )
//            query += ' LIMIT 100';
        return Database.getQueryLocator( query ); 
    }
//
// Common method to add a Sharing record into the list to be created
// 
	private void AddSharingRecordToList( List<Talent_Management__Share> myList, Id tmId, Id LeaderId ) {
        if( LeaderId != null )
            myList.add( new Talent_Management__Share( AccessLevel = 'Read',
                                                      ParentId = tmId,
                                                      RowCause = Schema.Talent_Management__Share.rowCause.Apex_Sharing_for_Hierarchy__c,
                                                      UserOrGroupId = LeaderId ) );
	}
    
    global void execute(Database.BatchableContext BC, List<Talent_Management__c> scope){
		// create a map of the records passed to the method 
        Map<Id, Talent_Management__c> tmMap = new Map<Id, Talent_Management__c>( scope );
        
        // list of sharing records to be deleted (= allow easy creation of new records)
        List<Talent_Management__Share> oldShare = [SELECT Id
                                                   FROM Talent_Management__Share
                                                   WHERE RowCause = :Schema.Talent_Management__Share.rowCause.Apex_Sharing_for_Hierarchy__c
                                                     AND ParentId IN :tmMap.keySet()];
        
        // list of sharing records to be created
        List<Talent_Management__Share> newShare = new List<Talent_Management__Share>();

        for( Talent_Management__c tm : scope )
            if( tm.User__r.IsActive  || test.isRunningTest() ) {
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_02__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_03__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_04__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_05__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_06__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_07__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_08__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_09__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_10__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_11__c );
                AddSharingRecordToList( newShare, tm.Id, tm.User__r.Mgmt_Chain_Hierarchy_Level_12__c );
            }

        try {
			// Delete the existing sharing records
            delete oldShare;

            // Insert new records
            Database.SaveResult[] resLst = Database.insert( newShare, false );

            // Process Exceptions
            Boolean blnEmail = FALSE;
            String strBody = '';
            for( Database.SaveResult res : resLst )
				if( !res.isSuccess() ) {
                    // Get the first save result error.
                    Database.Error err = res.getErrors()[0];
                   
                    // Check if the error is related to trivial access level.
                    // Access levels equal or more permissive than the object's default 
                    // access level are not allowed. 
                    // These sharing records are not required and thus an insert exception 
                    // is acceptable. 
                    if( !( err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                     &&  err.getMessage().contains( 'AccessLevel' ) ) ) {
                        // Error is not related to trivial access level.
                        // Send an email to the Apex job's submitter.
                        blnEmail = True;
                        strBody = strBody +
                                  'The Apex sharing recalculation threw the following exception: ' +
                                  err.getMessage() + '\r\n';
					}
                }
            if( blnEmail )
				SendEmail( 'Apex Sharing Recalculation Exception',
                           strBody );
        } catch(DmlException e) {
            SendEmail( 'Apex Sharing Recalculation Exception',
                       'The Apex sharing recalculation threw the following exception: ' + 
                        e.getMessage() );            
        }
    }
    
    global void finish(Database.BatchableContext BC){  
        SendEmail( 'Apex Sharing Recalculation Completed',
                   'The Apex sharing recalculation for Talent_Management finished processing' );
    }
    
    private void SendEmail( String Subject, String Message ) {
        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { myEmailAddress }; 
        newMail.setToAddresses( toAddresses ); 
        newMail.setSubject( Subject );
        newMail.setPlainTextBody( Message );
		if( !Test.isRunningTest() )
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newMail });
    }
}