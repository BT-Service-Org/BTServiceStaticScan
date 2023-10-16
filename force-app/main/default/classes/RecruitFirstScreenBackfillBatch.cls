global class RecruitFirstScreenBackfillBatch implements Database.Batchable<sobject>{

    private String Query='select Id,Candidate__c,RecordTypeName__c,Actual_Interview_Date__c from Interview__c' +
							' where Candidate__r.First_Screen_Date__c = null' + 
        					' and Actual_Interview_Date__c != null ';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
    	List<Interview__c> InterviewList = (list<Interview__c>)scope; 
       
        InterviewUtilities.UpdateDatesonRecruit (InterviewList);
        
    }
    global void finish(Database.BatchableContext BC)
    {

    }
    
}