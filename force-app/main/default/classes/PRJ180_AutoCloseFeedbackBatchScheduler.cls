/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For scheduling batch PRJ180_AutoCloseFeedbackBatch .
*/ 
global with sharing class PRJ180_AutoCloseFeedbackBatchScheduler implements Schedulable { 
	global void execute(SchedulableContext sc) {        
        PRJ180_AutoCloseFeedbackBatch batch = new PRJ180_AutoCloseFeedbackBatch();
        ID batchprocessid = Database.executeBatch(batch);
    }
}