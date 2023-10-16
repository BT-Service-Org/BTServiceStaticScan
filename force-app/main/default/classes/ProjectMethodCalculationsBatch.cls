/*
 * Description: This Class is used to run batches of onboarding projects and link them to the methods based on the project size
 * Date: 01-03-2023
 * */
global class ProjectMethodCalculationsBatch implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        // collect all projects based on stage and method for engagement status
       List<String> mfeStatusList = new List<String>(); 
       List<String> stageStatusList = new List<String>(); 
       List<String> stageNotProcessedList = new List<String>(); 

       String projectStatusDone= MethodologyConstants.PROJECT_STATUS_DONE;

       mfeStatusList.add(MethodologyConstants.PROJECT_STATUS_REFRESH);
       mfeStatusList.add(MethodologyConstants.PROJECT_NOT_STARTED);
       stageStatusList.add(MethodologyConstants.STATUS_DELIVERED);
       stageStatusList.add(MethodologyConstants.STATUS_COMPLETED);
       stageStatusList.add(MethodologyConstants.STATUS_CANCELLED);
       stageNotProcessedList.add(Label.Project_Status_Welcome_Sent);
       stageNotProcessedList.add(MethodologyConstants.PROJECT_STATUS_NOT_STARTED);

       String query = 'SELECT Id, Method_for_Engagement_status__c, Engagement_Size__c, Org62_Opportunity_Id__c, Opportunity__c, Preferred_Methodology__c, Offering__c, Bookings__c, Start_Date__c, End_Date__c, ProjectManagerUser__c, Project_Manager__r.User_Record__c FROM  PSA_Project__c WHERE Start_Date__c!=null and End_Date__c!=null and ((Method_for_Engagement_status__c!=null and Method_for_Engagement_status__c IN:mfeStatusList) OR (Method_for_Engagement_status__c=:projectStatusDone and Project_Setup_Status__c IN:stageNotProcessedList)) AND pse_Stage__c NOT IN:stageStatusList WITH SECURITY_ENFORCED';

       return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<PSA_Project__c> projList) {
        
        // process each batch of project records 
        try {
            ProjectMethodCalculationsBatchHandler.processMethodforProjectRecCreation(projList);}
        catch(Exception e) {
           System.debug(e);
        }
        }
         
    global void finish(Database.BatchableContext BC) {
    }
    }