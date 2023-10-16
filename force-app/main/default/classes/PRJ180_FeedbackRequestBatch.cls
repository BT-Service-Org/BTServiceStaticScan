/**
* @author         Vaishnavi Sreedhar <vaishnavi.sreedhar@salesforce.com>
* @created        09-05-2023
* @description    Batch implementation for PROJ-10: Sending Engagement Feedback Request on a schedule.
                  Creates Project 180 Engagement feedback for all Project Data with initiate feedback checked.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* @date           @modified           @description                    
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class PRJ180_FeedbackRequestBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator('SELECT Id, PA_Onboarding__c, Project_ID__c, Project_Role__c, Consultant__r.User_Record__c FROM PA_Onboarding_Project__c WHERE PRJ180_Initiate_Feedback__c = TRUE');
    } 
    
    public void execute(Database.BatchableContext bc, List<PA_Onboarding_Project__c> scope) { 
		String recTypeProject180 = 'PRJ180_Engagement_Feedback';
        Id recordTypeId = Schema.SObjectType.CSG_Project_Feedback__c.getRecordTypeInfosByDeveloperName().get(recTypeProject180).getRecordTypeId();
        Set<String> setOpenStatus = new Set<String>{'New','In Progress'};
        
        Set<ID> setOpenFeedback = new Set<ID>(); 
        for(CSG_Project_Feedback__c feedback: [SELECT Id, Assignment__c FROM CSG_Project_Feedback__c 
                                               WHERE RecordType.DeveloperName = :recTypeProject180 AND Assignment__c = :scope AND CSG_Feedback_Request_Status__c IN :setOpenStatus]){
        	setOpenFeedback.add(feedback.Assignment__c);		    
        }
        
        Map<String, Id> mapProjectManager = new Map<String, Id>();
        Map<String, Id> mapEngagementManager = new Map<String, Id>();
        Set<String> setProject = new Set<String>();
        for(PA_Onboarding_Project__c assignment: scope){
        	setProject.add(assignment.Project_ID__c);	    
        }
        for(PA_Onboarding_Project__c assignment: [SELECT Id, Project_ID__c, Project_Role__c, Consultant__r.User_Record__c FROM PA_Onboarding_Project__c 
                                                  WHERE Project_ID__c = :setProject AND (Project_Role__c LIKE '%Project Manager%' OR Project_Role__c LIKE '%Engagement Manager%')]){
           	String role = assignment.Project_Role__c.toLowerCase();
        	Map<String, Id> mapManager = role.contains('project manager') ? mapProjectManager : mapEngagementManager;
           	if(!mapManager.containsKey(assignment.Project_ID__c)){
            	mapManager.put(assignment.Project_ID__c, assignment.Consultant__r.User_Record__c);	                                              
        	}
        }
        
        List<CSG_Project_Feedback__c> listFeedbackInsert = new List<CSG_Project_Feedback__c>();
        List<PA_Onboarding_Project__c> listProjectDataUpdate = new List<PA_Onboarding_Project__c>();
        for(PA_Onboarding_Project__c assignment: scope){  
            String role = assignment.Project_Role__c?.toLowerCase();
            Id feedbackProvider;
           	Id projectManager = mapProjectManager.containsKey(assignment.Project_ID__c) ? mapProjectManager.get(assignment.Project_ID__c) : null;
            Id engagementManager = mapEngagementManager.containsKey(assignment.Project_ID__c) ? mapEngagementManager.get(assignment.Project_ID__c) : null;
            if(String.isNotBlank(role) && role.contains('engagement manager')){
            	feedbackProvider = projectManager;  
            }else if(String.isNotBlank(role) && role.contains('project manager')){
            	feedbackProvider = engagementManager;  
            }else{
            	feedbackProvider = projectManager != null ? projectManager : engagementManager;	    
            }              
            
             
            if(!setOpenFeedback.contains(assignment.Id) && (!PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Disable_Blank_Feedback_Provider__c || String.isNotBlank(feedbackProvider))){                
                CSG_Project_Feedback__c feedback = new CSG_Project_Feedback__c();
                feedback.RecordtypeId = recordTypeId;
                feedback.Assignment__c = assignment.Id;
                feedback.Onboarding__c = assignment.PA_Onboarding__c ;
                feedback.PRJ180_Feedback_Subject__c = assignment.Consultant__r.User_Record__c;
                feedback.CSG_Feedback_Provider__c = feedbackProvider;
                if(feedbackProvider != null) {
                feedback.ownerid = feedbackProvider;
                }    
                feedback.Unique_Feedback_Id__c = System.now() + '-' + assignment.Id;
                //feedback.PRJ180_Role_Description__c  = '';
                listFeedbackInsert.add(feedback);
            }else{
            	listProjectDataUpdate.add(new PA_Onboarding_Project__c(Id = assignment.Id, PRJ180_Initiate_Feedback__c = false));    
            }
        }
        
        if(!listFeedbackInsert.isEmpty()){
      		List<Database.SaveResult> result = Database.insert(listFeedbackInsert, false);
			for(Integer i = 0; i < result.size(); i++){
                if(result.get(i).isSuccess()){
                	listProjectDataUpdate.add(new PA_Onboarding_Project__c(Id = listFeedbackInsert[i].Assignment__c, PRJ180_Feedback_Sent_Date__c = System.today(), PRJ180_Initiate_Feedback__c = false));        
                }else{
                	List<Database.Error> listError = result.get(i).getErrors();
                	String error = !listError.isEmpty() ? listError[0].getMessage() : 'Error: Inserting Project 180 Engagement Feedback Request failed';
                    //Logger.error(listError[0].getMessage(), listFeedbackInsert[i].Id);                   
                }
        	}  
        }
        if(!listProjectDataUpdate.isEmpty()){
      		List<Database.SaveResult> result = Database.update(listProjectDataUpdate, false);
			for(Integer i = 0; i < result.size(); i++){
    			if(!result.get(i).isSuccess()){
                    List<Database.Error> listError = result.get(i).getErrors();
                	String error = !listError.isEmpty() ? listError[0].getMessage() : 'Error: Updating Project Data for fields Initiate Project 180 Feedback, Project 180 Feedback Sent Date failed';
                    //Logger.error(listError[0].getMessage(), listProjectDataUpdate[i].Id); 
                }
        	}    
        }
        
       // Logger.saveLog();
    }

    public void finish(Database.BatchableContext bc) {}   
}