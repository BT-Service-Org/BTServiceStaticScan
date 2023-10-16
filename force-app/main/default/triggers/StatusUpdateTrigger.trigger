trigger StatusUpdateTrigger on PeopleProfile__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
	 		List<PeopleProfile__c> newUserProfileList = new List<PeopleProfile__c>();
	        for(Integer i = 0; i < Trigger.old.size(); i++) {
	        	PeopleProfile__c n = Trigger.new[i];  	
	    		n.StatusLastModifiedDate__c=System.now();
	        	newUserProfileList.add(n);  
	        }
	        update newUserProfileList;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}   	
}