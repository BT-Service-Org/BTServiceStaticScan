trigger MainFeedTeamType on TeamType__c (after insert)  {
	if (!TeamUtil.currentlyExeTrigger) {
		try {
	
	  		List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        TeamType__c n = Trigger.new[i];
		        // Blurb:
		        minifeed.add( new MiniFeed__c( Type__c='AdminCreateNewType',
		                                           	User__c=n.CreatedById,
		                                           	FeedDate__c=System.now(),
		                                           	Message__c='created new team type ' + n.Name ));
		    }
		    insert minifeed;
		    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
}