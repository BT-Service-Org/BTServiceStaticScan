/**
 * Created by Rahul Mehta for PROJ-13 user story for Project 180 Feedback
 * For auto closing feedback on Inaction by making their status as Abandoned.
*/ 

public with sharing class PRJ180_AutoCloseFeedbackBatch implements Database.Batchable<sObject>,Database.Stateful {
    private static final String PRJ180_COMPLETE_FEEDBACK_STATUS = 'Completed';
    private static final String PRJ180_ABANDONED_FEEDBACK_STATUS = 'Abandoned';
    private static final String PRJ180_RECORD_TYPE_NAME = 'PRJ180_Engagement_Feedback';

    public Database.QueryLocator start(Database.BatchableContext bc) { 
    	String Query = 'SELECT ID, CSG_Feedback_Request_Status__c FROM CSG_Project_Feedback__c ' + 
                       'WHERE recordtype.developername = :PRJ180_RECORD_TYPE_NAME '+
                       'AND CSG_Feedback_Request_Status__c != :PRJ180_COMPLETE_FEEDBACK_STATUS ' +
                       'AND PRJ180_Notification__c = 3 AND PRJ180_Feedback_Completion_End_Date__c = Today';
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext bc, List<CSG_Project_Feedback__c> scope) { 
    	for(CSG_Project_Feedback__c c: scope) {
        	c.CSG_Feedback_Request_Status__c = PRJ180_ABANDONED_FEEDBACK_STATUS;
        }
        Database.SaveResult[] srList = Database.update(scope, false);
	    /* Commented till QA org gets Nebula logger        
		// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
        	if (!sr.isSuccess()) {
        		// Operation failed, so get all errors                
        		for(Database.Error err : sr.getErrors()) {
                	Logger.error(err.getMessage());  
             	}
    		}
		}
    	// Logger.saveLog();
		*/    
	}

    public void finish(Database.BatchableContext bc) {

    }
}