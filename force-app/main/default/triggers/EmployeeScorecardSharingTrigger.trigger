trigger EmployeeScorecardSharingTrigger on Employee_Scorecard__c (after insert, after update) {

	Id userId = UserInfo.getUserId();
	
	For (Employee_Scorecard__c es:Trigger.New){
		if(es.Employee_Name__c != userId){
			EmployeeScorecardSharing.manualShareAll(es.Id, userId);
		}
		
		EmployeeScorecardSharing.manualShareAll(es.Id, es.Manager_Name__c);
	}

}