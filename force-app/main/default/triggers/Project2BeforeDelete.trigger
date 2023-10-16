trigger Project2BeforeDelete on Project2__c bulk(before delete) {
    if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			
			List<ProjectTask__c> projectTaskList = [Select Id from ProjectTask__c where Project__c in :Trigger.old  ];    	
			delete projectTaskList; 
			
			List<ProjectIssue__c> projectIssueList = [Select Id from ProjectIssue__c where Project__c in :Trigger.old  ];    	
			delete projectIssueList;  
			
			List<ProjectRisk__c> projectRiskList = [Select Id from ProjectRisk__c where Project__c in :Trigger.old  ];    	
			delete projectRiskList;   	
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
}