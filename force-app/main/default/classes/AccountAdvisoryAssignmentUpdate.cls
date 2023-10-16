global class AccountAdvisoryAssignmentUpdate implements Database.Batchable<sObject>,Schedulable {

    
   private String Query='select Id,Account__c from PA_Onboarding_Project__c where'
       				+ ' Opportunity__r.Type in (\'ITC\',\'BTA\',\'Program Architect\') ';
    
    global void execute(schedulableContext sc)
    {
        Database.executebatch(this);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        return Database.getQueryLocator(query);
    }
 
        global void execute(Database.BatchableContext BC,List<sobject> scope)
    {
       system.debug(Scope);
        List<PA_Onboarding_Project__c> ProjectData = (List<PA_Onboarding_Project__c>)scope;
        Set<Id> AcctId = new Set<Id>();
       List<Account> AcctPAFlag = new List<Account>();
        List<Account> AcctBAFlag = new List<Account>();
        List<Account>AcctITCFlag = new List<Account>();

            
        for (PA_Onboarding_Project__c a :ProjectData)
        {
				AcctId.add(a.Account__c);
        }  
        
        for (Account ac : [select Id,(select Id,Opportunity__r.Type from Project_Data__r where
                                     Description__c != 'exclude' and Project_Status__c = 'Scheduled'
                                      and Opportunity__r.Type = 'Program Architect') from Account where Id = :AcctId ])
        {
            Account AcctPAUpd = new Account();
            AcctPAUpd.Id = ac.Id;
            AcctPAUpd.Active_PA_Assignments__c=ac.Project_Data__r.size() > 0 ? ac.Project_Data__r.size() : 0;
            AcctPAFlag.add(AcctPAUpd);
        }
        
        for (Account ac : [select Id,(select Id,Opportunity__r.Type from Project_Data__r where
                                     Description__c != 'exclude' and Project_Status__c = 'Scheduled'
                                      and Opportunity__r.Type = 'BTA') from Account where Id = :AcctId ])
        {
            Account AcctBAUpd = new Account();
            AcctBAUpd.Id = ac.Id;
            AcctBAUpd.Active_BA_Assignments__c = ac.Project_Data__r.size() > 0 ? ac.Project_Data__r.size() : 0;
            AcctBAFlag.add(AcctBAUpd);
            
        }
        
        for (Account ac : [select Id,(select Id,Opportunity__r.Type from Project_Data__r where
                                     Description__c != 'exclude' and Project_Status__c = 'Scheduled'
                                      and Opportunity__r.Type = 'ITC') from Account where Id = :AcctId ])
        {
                Account AcctITCUpd = new Account();
                AcctITCUpd.Id = ac.Id;
                AcctITCUpd.Active_ITC_Assignments__c = ac.Project_Data__r.size() > 0 ? ac.Project_Data__r.size() : 0;
                AcctITCFlag.add(AcctITCUpd);
        }

        
        Database.Update (AcctPAFlag,true);
        Database.Update (AcctBAFlag,true);
        Database.Update (AcctITCFlag,true);

	}

    global void finish(Database.BatchableContext BC)
    {

    }  


}