trigger MainFeedTeamProfile on TeamProfile__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
	
		 	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        TeamProfile__c n = Trigger.new[i];	
		        minifeed.add( new MiniFeed__c( Type__c='AdminNewTeamProfile',
		                                           	User__c=n.CreatedById,
		                                           	FeedDate__c=System.now(),
		                                           	Message__c='created a new Team Profile ' + n.Name));
		    }
		    insert minifeed;
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}	
}