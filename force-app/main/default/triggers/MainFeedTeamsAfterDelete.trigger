trigger MainFeedTeamsAfterDelete on Team__c bulk (after delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
	        for(Integer i = 0; i < Trigger.old.size(); i++) {
	            Team__c o = Trigger.old[i];
	            // Blurb:
	            minifeed.add( new MiniFeed__c( Type__c='TeamDelete',
	                                            FeedDate__c=System.now(),
	                                            User__c=UserInfo.getUserId(),
	                                          	Message__c=' deleted team ' + o.Name));
	        }
	  		insert minifeed;
	  		
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}