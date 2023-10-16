trigger BookmarkBeforeDelete on Bookmark__c bulk (before delete) {
    Bookmark__c[] b = Trigger.old;
    if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
		    //Remove Related Blog Comments
		    List<Comment__c> bookmarkComments = [SELECT Id FROM Comment__c WHERE Bookmark__c in :Trigger.old];                     
		    delete bookmarkComments;    
	    } finally {
    		TeamUtil.currentlyExeTrigger = false;
		}
	} 
}