public with sharing class WelcomeMessageBatch extends BaseSchedulableBatch{

    public Database.QueryLocator start(Database.BatchableContext bc){

        String pmRolesIdentifier = '%'+MethodologyConstants.ROLE_PROJECT_MANAGER+'%';
        String  query = 'SELECT Id, Resource__c, PSA_Project__c, PSA_Project__r.Name, PSA_Project__r.Org62_Id__c, End_Date__c, Project_Role__c FROM Project_Assignment__c WHERE Start_Date__c <= TODAY AND ( PSA_Project__r.Project_Setup_Status__c = \''+Label.Project_Status_Complete_Smartsheet_Sent+'\') AND (NOT Project_Role__c like :pmRolesIdentifier)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){

        List<Project_Assignment__c> assignments = (List<Project_Assignment__c>)scope;
        if(assignments != null && !assignments.isEmpty()){
            try{
                MTH_SlackAppMessenger messenger = new MTH_SlackAppMessenger();
                messenger.sendWelcomeMessages(assignments);
            }
            catch(Exception ex){
                handleException(ex);
            }
            
        }
        
    }

    public void finish(Database.BatchableContext bc){
        scheduleNext(KickoffMessagesBatch.class);
    }

    public void execute(SchedulableContext sc){
        WelcomeMessageBatch batch = new WelcomeMessageBatch();
        Database.executeBatch(batch);
    }
}