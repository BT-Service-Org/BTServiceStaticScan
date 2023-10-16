trigger MainFeedCompetenciesAfterUpdate on UserCompetencies__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
    		
    		for(Integer i = 0; i < Trigger.old.size(); i++) {
		    	UserCompetencies__c o = Trigger.old[i];
		        UserCompetencies__c n = Trigger.new[i];
		        
		        if((n.Rating__c != o.Rating__c) || (n.Name != o.Name)) {
		
		            minifeed.add( new MiniFeed__c( Type__c='PeopleCompetencyChange',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their competency list' ));
		    	}
		    }
    		insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 				
}