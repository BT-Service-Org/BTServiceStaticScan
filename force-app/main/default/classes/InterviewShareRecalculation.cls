global class InterviewShareRecalculation implements Database.Batchable<sObject> {
	
	string query = 'select Id, Interviewer__c from Interview__c where Interviewer__c != null';
	
	global InterviewShareRecalculation() 
	{
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		InterviewUtilities.AddInterviewShares(new Map<Id, Interview__c>((List<Interview__c>)scope));
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		
	}
}