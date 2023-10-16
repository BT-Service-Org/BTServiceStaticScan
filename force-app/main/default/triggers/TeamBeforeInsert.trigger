trigger TeamBeforeInsert on Team__c bulk (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			for (Team__c t : Trigger.new) {
				
				t.TeamCreatedDate__c = System.now();
				t.TeamCreatedBy__c = UserInfo.getUserId();
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}