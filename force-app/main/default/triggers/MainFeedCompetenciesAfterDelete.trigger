trigger MainFeedCompetenciesAfterDelete on UserCompetencies__c bulk (after delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();

    		for(Integer i = 0; i < Trigger.old.size(); i++) {
		        UserCompetencies__c o = Trigger.old[i];
		        minifeed.add( new MiniFeed__c( Type__c='PeopleCompetencyChange',
		                                           User__c=o.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their competency list' ));
		    }
    		insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 				
}