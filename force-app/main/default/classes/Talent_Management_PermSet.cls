global without sharing class Talent_Management_PermSet implements Database.Batchable<sObject> {
//
// Email address from the person who launched the Batch
// used for sending all messages (Exceptions, End of Batch, etc.)
// 
	final private String myEmailAddress;
    
    final private Id PermSetId;
    final private String FilterStr;
//
// Constructor:
//   - Store the email address
//   - Identify the Permission Set Id
//   - Store the Filter to apply on Users
// 
    public Talent_Management_PermSet( TM_Tech_Batch__c BatchRecord ) {
        myEmailAddress = UserInfo.getUserEmail();
        
        List<PermissionSet> PSlst = [SELECT Id FROM PermissionSet WHERE Name = 'Talent_Management_User'];
        if( PSlst.size() > 0)
            PermSetId = PSlst[0].Id;
        
        FilterStr = BatchRecord.Filter__c;
    }
//
//
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String query = 'SELECT Id ' +
            		   'FROM User ' +
            		   'WHERE IsActive = True ' +
            		   'AND ' + FilterStr + ' ' +
            		   'AND Id NOT IN ( ' +
										'SELECT AssigneeId ' +
            							'FROM PermissionSetAssignment ' +
            							'WHERE PermissionSetId = :PermSetId )';
        if( Test.isRunningTest() )
            query += ' LIMIT 100';
        return Database.getQueryLocator( query ); 
    }
//
//
//      
    global void execute(Database.BatchableContext BC, List<User> Scope){

        List<PermissionSetAssignment> newLst = new List<PermissionSetAssignment>();
        for( User Cur : Scope ) {
            PermissionSetAssignment newPS = new PermissionSetAssignment( AssigneeId = Cur.Id,
                                                                         PermissionSetId = PermSetId );
            newLst.add( newPS );
        }
            
        try {
            // Insert new records
            Database.SaveResult[] resLst = Database.insert( newLst, false );

            // Process Exceptions
            for( Database.SaveResult res : resLst )
				if( !res.isSuccess() ) {
                    // Get the first save result error.
                    Database.Error err = res.getErrors()[0];
                }

        } catch(DmlException e) {
            SendEmail( 'Permission Set Grant Exception',
                       'Granting Permission Set threw the following exception: ' + 
                        e.getMessage() );            
        }
    }
    
    global void finish(Database.BatchableContext BC){  
        SendEmail( 'Permission Set Granted',
                   'All Users in ProServ have been granted access to the App' );
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