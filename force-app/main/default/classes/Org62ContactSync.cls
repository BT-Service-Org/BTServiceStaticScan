//Contact sync to bring utilization and resource role details
global class Org62ContactSync implements Database.Batchable<sObject> {
     private String query = 'select Id, Candidate_Email__c, Contact__c, Candidate__r.Org62_User_Id__c ' +
                             ' from PA_Onboarding__c where Active_User__c=true ' ;  
    
    global void execute(schedulableContext sc) {
        Database.executebatch(this);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC,List<sobject> scope)
    {
        System.debug('scope ' + scope);
        List<PA_Onboarding__c> onbLs = (List<PA_Onboarding__c>)scope;
        
        Set<Id> org62Id = new Set<Id>();
        for (PA_Onboarding__c onb : onbLs ) {
            
            if (onb.Candidate__r.Org62Id__c != null) {
                org62Id.add(onb.Candidate__r.Org62Id__c);
            }
        }
        
        System.debug('org62id ' + org62Id.size());
        
        List<User> updls = new List<User>();
        Map<String, Contact__x> extContactMap = new Map<String, Contact__x>();
        for (Contact__x extCon: [select ExternalId, RecordTypeId__c,Email__c, Name__c, 
            pse_Is_Resource_c__c,pse_Is_Resource_Active_c__c,pse_Region_c__c, pse_Resource_Role_c__c,
            pse_Salesforce_User_c__c,pse_Utilization_Target_c__c,
            (select Id, pse_Historical_Billable_Hours_c__c , pse_Historical_Calendar_Hours_c__c, Actual_Target_Hours_c__c,
                pse_Historical_Credited_Hours_c__c from Utilization_Details__r where pse_Is_Report_Master_c__c = 'true') 
            
             from Contact__x where 
                    ( pse_Salesforce_User_c__c in: org62Id ) ]) {
            extContactMap.put(extCon.pse_Salesforce_User_c__c, extCon);
        }
        
        Set<Id> uid = new Set<Id>();    
        for (PA_Onboarding__c onb : onbLs) {
           System.debug('In the loop' + onb);
           if (extContactMap.containskey(onb.Candidate__r.Org62Id__c)) {
                Contact__x extCon = extContactMap.get(onb.Candidate__r.Org62Id__c);
                System.debug('extCon ' + extCon.ExternalId);
                //set fields (role, util) on onboarding
           }
        }
    }
     
    
    global void finish(Database.BatchableContext BC) {
        //updateJobStatusLog(jobId, BC, errorLog);
       
    }
}