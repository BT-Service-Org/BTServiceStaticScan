/**
 * Created Date: June 23rd,2020
 * For EA Experise App use only.
 * 
 * */
global class deleteOnboardingBadgeData implements Database.Batchable<SObject>,Database.Stateful  {
    
	global String query;
    global String selectString; 
    global System.LoggingLevel level = LoggingLevel.ERROR;
    sObject[] source;
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query;
        if(Test.isRunningTest()){
            query ='Select Id from Onboarding_Badge_Data__c where Unique_Id__c like \'Test%\'';
        }else{
             query = 'Select Id from Onboarding_Badge_Data__c';//Onboarding_Badge_Data
	       
    	  } 
         System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Onboarding_Badge_Data__c > scope) {
		delete scope;
        Database.emptyRecycleBin(scope); 
    }
    
    global void finish(Database.BatchableContext BC) {
        createOnboardingBadgeData myBatchObject = new createOnboardingBadgeData(); 
        Id batchId = Database.executeBatch(myBatchObject);
    }
}