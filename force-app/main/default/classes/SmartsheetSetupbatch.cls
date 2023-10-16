//global with sharing class SmartsheetSetupbatch implements Database.Batchable<SObject>{
    public without sharing class SmartsheetSetupbatch extends BaseSchedulableBatch{
    
        public Database.QueryLocator start(Database.BatchableContext bc){
            
            String  query = 'SELECT Id, Project_Setup_Status__c,(SELECT Id, PSA_Project__c, Assigned_Resource__c FROM Method_for_Projects__r) FROM PSA_Project__c where Project_Setup_Status__c = \''+Label.Project_Status_Project_Parameters_Set+'\'';
            return Database.getQueryLocator(query);
        }
    
        public void execute(Database.BatchableContext bc, List<SObject> scope){
    
            List<PSA_Project__c> projects = (List<PSA_Project__c>)scope;
            List<PSA_Project__c> projectsToBeUpdated = new  List<PSA_Project__c>();
            if(projects != null && !projects.isEmpty()){
    
                try{
                    List<Methods__c> methodEngagments = new List<Methods__c>();
                    for(PSA_Project__c proj : projects){
                        Boolean hasMFE = false;
                        for(Methods__c method : proj.Method_for_Projects__r){
                            methodEngagments.add(method);
                            hasMFE = true;
                        }
                        if(hasMFE){
                            projectsToBeUpdated.add(proj);
                        }
                    }
    
                    if(!methodEngagments.isEmpty()){
    
                    // This is being commented out as the async process is now changed to real time through flow.
                        //MTH_SlackAppMessenger messenger = new MTH_SlackAppMessenger();
                        //messenger.sendSmartsheetMessages(methodEngagments);
     
                        for(PSA_Project__c proj: projectsToBeUpdated){
                            proj.Project_Setup_Status__c = Label.Project_Status_Complete_Smartsheet_Sent;
                        }
                    }
                    
                    if(!projectsToBeUpdated.isEmpty()){
                        Database.update(projectsToBeUpdated, false);
                    }
                }
                catch(Exception ex){
                    handleException(ex);
                }
                
            }
            
        }
    
        public void finish(Database.BatchableContext bc){
            scheduleNext(SmartsheetSetupbatch.class);
        }
    
        public void execute(SchedulableContext sc){
            SmartsheetSetupbatch batch = new SmartsheetSetupbatch();
            Database.executeBatch(batch);
        } 
    }