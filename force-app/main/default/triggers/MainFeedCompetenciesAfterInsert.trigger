trigger MainFeedCompetenciesAfterInsert on UserCompetencies__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();

    		for(Integer i = 0; i < Trigger.new.size(); i++) {

        		UserCompetencies__c n = Trigger.new[i];
        		minifeed.add( new MiniFeed__c( Type__c='PeopleCompetencyChange',
                                           User__c=n.User__c,
                                           FeedDate__c=System.now(),
                                           Message__c='has updated their competency list' ));
    		}
    		insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 				
}