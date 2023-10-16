trigger MainFeedEmploymentAfterInsert on EmploymentHistory__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        EmploymentHistory__c n = Trigger.new[i];
		        // We need to:
		        minifeed.add( new MiniFeed__c( Type__c='PeopleEmploymentChange',
		                                           User__c=n.User__c,
		                                           FeedDate__c=System.now(),
		                                           Message__c='has updated their employment history' ));
		    }
		    insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 			
}