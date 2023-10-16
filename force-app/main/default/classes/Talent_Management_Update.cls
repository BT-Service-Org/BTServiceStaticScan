global without sharing class Talent_Management_Update implements Database.Batchable<sObject> {

	final private String myEmailAddress;
    private Integer UpdatedRecords;

    public Talent_Management_Update() {
        myEmailAddress = UserInfo.getUserEmail();
        UpdatedRecords = 0;
    }

	global void finish(Database.BatchableContext BC) {
        SendEmail( 'Talent Management update process finished',
                   '' + UpdatedRecords + ' records for Talent Management have been updated' );
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        String query = 'SELECT Id, ' +
            			'User__c, ' +
            			'User__r.Org62Id__c, ' +
            			'Achieved_Certifications__c, ' +
            			'Career_Profile__c, ' +
            			'Career_Expected__c, ' +
                        'Career_Readiness__c, ' +
                        'Career_Rated__c, ' +
                        'Career_Validated__c, ' +
                        'Career_Match_pct__c, ' +
                        'Career_Match__c, ' +
                        'Career_Validated_pct__c, ' +
                        'Opportunity_Profile__c, ' +
                        'Opportunity_Expected__c, ' +
                        'Opportunity_Readiness__c, ' +
                        'Opportunity_Match__c, ' +
                        'Opportunity_Match_pct__c, ' +
                        'Opportunity_Validated_pct__c ' +
                        'FROM Talent_Management__c ' +
            			'WHERE User__r.IsActive = True';
        if( test.isRunningTest() )
            query += ' LIMIT 10';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Talent_Management__c> lstTM) {
        List<Id> lstUsr = new List<Id>();
        Map<Id, Id> mapOnboarding = new Map<Id, Id>();
        
        for( Talent_Management__c curTM : lstTM ) {
            LGdata curLG = new LGdata(curTM);
			curLG.ClearLists();
            lstUsr.add(curTM.User__c);
            UpdatedRecords++;
        }

        for( PA_Onboarding__c curOnb : [SELECT Id, Candidate__c
                                        FROM PA_Onboarding__c
                                        WHERE Candidate__c IN :lstUsr] )
            mapOnboarding.put(curOnb.Candidate__c, curOnb.Id);
        
		for( Talent_Management__c curTM : lstTM )
            if( mapOnboarding.containsKey( curTM.User__c ) )
            	curTM.Onboarding__c = mapOnboarding.get( curTM.User__c );
            
        try {
            update lstTM;
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