/**
* @author         Vaishnavi Sreedhar <vaishnavi.sreedhar@salesforce.com>
* @created        09-05-2023
* @description    Schedule and batch implementation for PROJ-10: Sending Engagement Feedback Request on a schedule.
Checks the flag Initiate Project 180 Feedback on Project Data, calls PRJ180_FeedbackRequestBatch in finish.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* @date           @modified           @description                    
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class PRJ180_InitiateFeedbackRequestBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<PRJ180_Feedback_ApplicableCountries__mdt> lstmdt = PRJ180_Feedback_ApplicableCountries__mdt.getall().values();
        List<String> lstcountry = new List<String>();
        for(PRJ180_Feedback_ApplicableCountries__mdt m: lstmdt) {
            lstcountry.add(m.masterlabel);      
        }
        Set<Id> setPAOnbPrj = new Set<Id>();
        String strRoleLike = '%- 0 rate%';
        for(PA_Onboarding_Project__c objPrj: [Select Id, Project_Start_Date__c, Project_End_Date__c from PA_Onboarding_Project__c WHERE Type__c = 'Billable' AND PRJ180_Initiate_Feedback__c = FALSE AND (Billable_Hours__c > 0 OR Project_Role__c LIKE :strRoleLike) AND Project_End_Date__c = THIS_WEEK AND PA_Onboarding__r.Country_From_User_Record__c in :lstcountry]){
            Date startDate = objPrj.Project_Start_Date__c;
            Date endDate = objPrj.Project_End_Date__c;
            if(startDate!=null && endDate!=null){
                if(startDate.daysBetween(endDate) <=28){
                    setPAOnbPrj.add(objPrj.Id);
                }
            }
            
        }
        
        String query = 'SELECT Id FROM PA_Onboarding_Project__c WHERE Id Not in:setPAOnbPrj AND Type__c = \'Billable\' AND PRJ180_Initiate_Feedback__c = FALSE AND (Billable_Hours__c > 0 OR Project_Role__c LIKE :strRoleLike) AND  ';
        String endDateAndCountryCriteria = 'Project_End_Date__c = THIS_WEEK AND PA_Onboarding__r.Country_From_User_Record__c in :lstcountry'; 
        String sixMonthCriteria = 'Project_Start_Date__c < LAST_N_MONTHS:6 AND Project_End_Date__c > TODAY AND PRJ180_Feedback_Completion_Date__c < LAST_N_MONTHS:6';
        query += PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Enable_6_Month_Feedback_Request__c ? '((' + endDateAndCountryCriteria + ') OR (' + sixMonthCriteria + '))' : endDateAndCountryCriteria ;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<PA_Onboarding_Project__c> scope) { 
        for(PA_Onboarding_Project__c assignment: scope){
            assignment.PRJ180_Initiate_Feedback__c = true;    
        }
        system.debug('=='+scope);
        List<Database.SaveResult> result = Database.update(scope, false);
        for(Integer i = 0; i < result.size(); i++){
            if(!result.get(i).isSuccess()){
                List<Database.Error> listError = result.get(i).getErrors();
                String error = !listError.isEmpty() ? listError[0].getMessage() : 'Error: Updating Initiate Feedback checkbox failed';
                //Logger.error(listError[0].getMessage(), scope[i].Id);
            }
        }
        //Logger.saveLog();
    }
    
    public void finish(Database.BatchableContext bc) {
        Integer batchSize = (Integer) PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Feedback_Request_Batch_Size__c;
        Database.executeBatch(new PRJ180_FeedbackRequestBatch(), batchSize != null ? batchSize : 2000);
    }
    
    public void execute(SchedulableContext sc) {   
        Integer batchSize = (Integer) PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Initiate_Feedback_Batch_Size__c ;
        Database.executeBatch(new PRJ180_InitiateFeedbackRequestBatch(), batchSize != null ? batchSize : 2000);
    }
}