trigger BlogEntryBeforeDelete on BlogEntry__c bulk (before delete) {
	BlogEntry__c[] b = Trigger.old;
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			//Remove Related Blog Comments
		    List<Comment__c> blogComments = [SELECT Id FROM Comment__c WHERE BlogEntry__c in :Trigger.old];                     
		    delete blogComments; 
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}