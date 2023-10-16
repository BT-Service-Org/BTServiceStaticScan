global without sharing class Talent_Management_Batch implements Database.Batchable<sObject> {

    final TM_Tech_Batch__c myBatch;
	final private String myEmailAddress;

    public Talent_Management_Batch( TM_Tech_Batch__c BatchRecord ) {
        myBatch = BatchRecord;
        myEmailAddress = UserInfo.getUserEmail();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        String query = 'SELECT Id, JobCode__c FROM User WHERE IsActive=True AND ' + myBatch.Filter__c +
            ' AND Id NOT IN (SELECT User__c FROM Talent_Management__c)';
        if( test.isRunningTest() )
            query += ' LIMIT 10';
        return Database.getQueryLocator(query);
    }

	global void finish(Database.BatchableContext BC) {
        myBatch.Finished__c = True;
        try {
            update myBatch;
			SendEmail( 'Talent Management initiation process finished',
            	       'The records for Talent Management have been created for filter ' + myBatch.Filter__c );

        } catch(Exception e) {
            SendEmail( 'Talent Management initiation process Exception',
                       'The batch creation threw the following exception: ' + 
                        e.getMessage() );
        }

    }

    global void execute(Database.BatchableContext BC, List<User> lstUser) {
        
        List<Talent_Management__c> lstNew = new List<Talent_Management__c>();
        
        for(User curUsr : lstUser) {        
            String strJobCode = '' + curUsr.JobCode__c;
            String strGrade = '0';
            String strFamily = '0';
            if( strJobCode.length() == 6 ) {
                strGrade = strJobCode.right(2);
                strFamily = strJobCode.left(3);
            }
            Career_Profile__c sProfile;
            if(Test.isRunningTest())
                sProfile = Talent_Management_Test.CreateTestData();
            else
                sProfile = [SELECT Id
                            FROM Career_Profile__c
                            WHERE ( Job_Grade__c = :strGrade
                              AND Job_Families__c = :strFamily )
                            OR Career_Path__c = 'None'
                            ORDER BY Job_Grade__c DESC][0];
            Talent_Management__c newTM = new Talent_Management__c();
            newTM.Career_Profile__c = sProfile.Id;
            newTM.Opportunity_Profile__c = sProfile.Id;
            newTM.ownerId = curUsr.Id;
            newTM.User__c = curUsr.Id;
            lstNew.add(newTM); 
        }
        try {
            insert lstNew;
        } catch(Exception e) {
            SendEmail( 'Talent Management initiation process Exception',
                       'The batch creation threw the following exception: ' + 
                        e.getMessage() );
        }
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