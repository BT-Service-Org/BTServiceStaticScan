trigger ProjectTaskAfterDelete on ProjectTask__c bulk(after delete) {
    if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			
			List<ProjectAssignee__c> projectAssigneeList = [select Id from ProjectAssignee__c where ProjectTask__c in :Trigger.old];    	
			delete projectAssigneeList; 
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}  	
}