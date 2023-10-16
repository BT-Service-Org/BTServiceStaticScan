trigger ProjectTaskBeforeDelete on ProjectTask__c bulk(before delete) {
  
  	ProjectTask__c[] p = Trigger.old;
  	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			List<ProjectAssignee__c> projectAssigneeList = [Select Id from ProjectAssignee__c where ProjectTask__c in :Trigger.old  ];    	
			delete projectAssigneeList;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}