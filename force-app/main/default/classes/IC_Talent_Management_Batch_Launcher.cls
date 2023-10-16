public without sharing class IC_Talent_Management_Batch_Launcher {

    private final TM_Tech_Batch__c myBatch;
    
    public IC_Talent_Management_Batch_Launcher(ApexPages.StandardController stdController) {
        this.myBatch = (TM_Tech_Batch__c) stdController.getRecord();
    }

    public PageReference RecalculateSharing() {
		Database.executeBatch( new Talent_Management_Sharing() );
        return NULL;
    }

    public PageReference GrantPermSet() {
		Database.executeBatch( new Talent_Management_PermSet( myBatch ) );
        return NULL;
    }

    public PageReference UpdateAllRecords() {
		Database.executeBatch( new Talent_Management_Update(), 40 );
        return NULL;
    }

	public PageReference LaunchCreations() {
        if( myBatch.Filter__c != '' ) {
            myBatch.Finished__c = False;
            myBatch.Last_launched__c = datetime.now();
            try {
                update myBatch;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            Talent_Management_Batch myBatchObject = new Talent_Management_Batch( myBatch ); 
            Id batchId = Database.executeBatch(myBatchObject, 50);
        }
        return NULL;
    }

    public PageReference UpdateNumbers() {
        myBatch.Users_in_Org__c = 0;
        myBatch.Users_with_a_Record__c = 0;
        myBatch.Record_Creation__c = 0;
        List<User> lstUsr = [SELECT Id,
                             Mgmt_Chain_Hierarchy_Level_02__c,
                             Mgmt_Chain_Hierarchy_Level_03__c,
                             Mgmt_Chain_Hierarchy_Level_04__c,
                             Mgmt_Chain_Hierarchy_Level_05__c,
                             Mgmt_Chain_Hierarchy_Level_06__c,
                             Mgmt_Chain_Hierarchy_Level_07__c,
                             Mgmt_Chain_Hierarchy_Level_08__c,
                             Mgmt_Chain_Hierarchy_Level_09__c,
                             Mgmt_Chain_Hierarchy_Level_10__c,
                             Mgmt_Chain_Hierarchy_Level_11__c,
                             Mgmt_Chain_Hierarchy_Level_12__c
                             FROM User WHERE Id = :myBatch.Leader__r.Id];
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ' + lstUsr.size());
        if( lstUsr.size() != 0 ) {
            User Usr = lstUsr[0];
            myBatch.Filter__c = '';
            String Level = '';
            if( Usr.Mgmt_Chain_Hierarchy_Level_02__c == NULL ) Level = '02';
			else if( Usr.Mgmt_Chain_Hierarchy_Level_03__c == NULL ) Level = '03';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_04__c == NULL ) Level = '04';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_05__c == NULL ) Level = '05';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_06__c == NULL ) Level = '06';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_07__c == NULL ) Level = '07';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_08__c == NULL ) Level = '08';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_09__c == NULL ) Level = '09';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_10__c == NULL ) Level = '10';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_11__c == NULL ) Level = '11';
            else if( Usr.Mgmt_Chain_Hierarchy_Level_12__c == NULL ) Level = '12';
            if( Level == '' )
	            myBatch.Manager_Level__c = '';
            else {
	            myBatch.Manager_Level__c = 'L ' + Level;
                myBatch.Filter__c = 'Mgmt_Chain_Hierarchy_Level_' + Level + '__c = \'' + Usr.Id + '\'';
	            myBatch.Users_in_Org__c = database.countQuery('SELECT count() FROM User WHERE IsActive = TRUE AND ' + myBatch.Filter__c);
                myBatch.Users_with_a_Record__c = database.countQuery('SELECT count() FROM Talent_Management__c WHERE User__r.IsActive = TRUE and User__r.' + myBatch.Filter__c);
				myBatch.Record_Creation__c = myBatch.Users_in_Org__c - myBatch.Users_with_a_Record__c;
            }
        }
        try {
            update myBatch;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return NULL;
    }
}