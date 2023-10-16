trigger DiscussionTopicBeforeDelete on DiscussionTopic__c bulk (before delete) {
    if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			List<DiscussionMessage__c> msgList = [select Id from DiscussionMessage__c where DiscussionTopic__c in :Trigger.old];    	
			delete msgList;  	  
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}
}