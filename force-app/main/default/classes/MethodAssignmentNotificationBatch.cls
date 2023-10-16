public without sharing class MethodAssignmentNotificationBatch extends BaseSchedulableBatch{
    public string querystring;

    public Database.QueryLocator start(Database.BatchableContext bc){
        String  query = 'SELECT Id, Project_Setup_Status__c,(SELECT Id, PSA_Project__c, Assigned_Resource__c, Start_Date__c, End_Date__c, Method__r.name, Method__r.id FROM Method_for_Projects__r where assigned_Resource__c != null and Start_Date__c != null and End_date__c != null) FROM PSA_Project__c WHERE Project_Setup_Status__c = \''+Label.Project_Status_Message_Sent_With_Product_Details+'\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        List<PSA_Project__c> psaProjectList = (List<PSA_Project__c>)scope;
        List<PSA_Project__c> projectsToBeUpdated = new List<PSA_Project__c>();
        List<Methods__c> methodforEngagementList = new List<Methods__c>();
        for(PSA_Project__c psaProject : psaProjectList)
        {
            Boolean hasMFE = false;
            for(Methods__c method : psaProject.Method_for_Projects__r){
                methodforEngagementList.add(method);
                hasMFE = true;
            }
            if(hasMFE){
                psaProject.Project_Setup_Status__c = Label.Project_Status_Message_Notification_Sent_To_Resources;
                projectsToBeUpdated.add(psaProject);
            }       
        }

        try{
            if(!methodforEngagementList.isEmpty())
            {
                MTH_SlackAppMessenger messenger = new MTH_SlackAppMessenger();
                messenger.sendMethodAssignedMessages(methodforEngagementList);                       
            }

            if(!projectsToBeUpdated.isEmpty()){
                Database.update(projectsToBeUpdated, false);
            }
        }
        catch(Exception ex){
            handleException(ex);
        }
    }

    public void finish(Database.BatchableContext bc){
        scheduleNext(MethodAssignmentNotificationBatch.class);
    }

    public void execute(SchedulableContext sc){
        MethodAssignmentNotificationBatch batch = new MethodAssignmentNotificationBatch();
        Database.executeBatch(batch);
    }
   
}