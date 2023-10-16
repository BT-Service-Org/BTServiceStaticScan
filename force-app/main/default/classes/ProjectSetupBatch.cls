public without sharing class ProjectSetupBatch extends BaseSchedulableBatch{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String  query = 'SELECT Id, Project_Setup_Status__c, Project_Manager__c, (SELECT Id FROM Method_for_Projects__r limit 1) FROM PSA_Project__c WHERE (Start_Date__c = TODAY OR Start_Date__c = NEXT_N_DAYS:10) AND Project_Setup_Status__c = \''+Label.Project_Status_Not_Started+'\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){

        Map<Id, PSA_Project__c> projectMap = new Map<Id, PSA_Project__c>((List<PSA_Project__c>)scope);
        Set<Id> projectIds = new Set<Id>();
        for(PSA_Project__c proj : projectMap.values()){
            if(proj.Method_for_Projects__r != null && proj.Method_for_Projects__r.size()>0){
                projectIds.add(proj.Id);
            }
        }

        if(projectIds.size() > 0){
            List<Project_Assignment__c> assignments = [SELECT Id,Resource__c,Project_Role__c, Status__c, Project_Name__c, PSA_Project__c, PSA_Project__r.Name, PSA_Project__r.Org62_Id__c,Start_Date__c  FROM Project_Assignment__c WHERE PSA_Project__c IN :projectIds AND Status__c = :MethodologyConstants.STATUS_SCHEDULED];

            if(assignments != null && assignments.size() > 0){

                try {
                    List<PSA_Project__c> projectsToBeUpdated = new List<PSA_Project__c>();
                    Set<Id> projectIdsToBeUpdated = new Set<Id>();
                    List<Project_Assignment__c> assignmentsToBeConsidered = new List<Project_Assignment__c>();

                    for(Project_Assignment__c assignment : assignments){
                        if(assignment.Resource__c != null && assignment.Resource__c == projectMap.get(assignment.PSA_Project__c)?.Project_Manager__c){
                            projectIdsToBeUpdated.add(assignment.PSA_Project__c);
                            assignmentsToBeConsidered.add(assignment);
                        }
                    }

                    for(Id projId : projectIdsToBeUpdated){
                        PSA_Project__c proj = projectMap.get(projId);
                        proj.Project_Setup_Status__c = Label.Project_Status_Welcome_Sent;
                        projectsToBeUpdated.add(proj);
                    }
                    
                    MTH_SlackAppMessenger messenger = new MTH_SlackAppMessenger();
                    messenger.sendSetupMessages(assignmentsToBeConsidered);

                    if(projectsToBeUpdated.size() > 0){
                        Database.update(projectsToBeUpdated, false);
                    }
                } 
                catch(Exception ex){
                    handleException(ex);
                }
                
            }
                
        }
    }

    public void finish(Database.BatchableContext bc){
        scheduleNext(ProjectSetupBatch.class);
    }

    public void execute(SchedulableContext sc){
        ProjectSetupBatch batch = new ProjectSetupBatch();
        Database.executeBatch(batch);
    }
   
}