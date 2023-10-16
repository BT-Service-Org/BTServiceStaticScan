trigger MainFeedDiscussionTopic on DiscussionTopic__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {		
			
			/**
			* This happens after insert
			*/		
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
			
			List<String> idsTeam = new List<String>();
			for (DiscussionTopic__c iterTopic : Trigger.new) {
				idsTeam.add(iterTopic.team__c);	
			}
			List<Team__c> teamList = [select Name, Id from Team__c where Id in: idsTeam];
			
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        DiscussionTopic__c n = Trigger.new[i];
				Team__c Team;
				Boolean findTeam = false;
				Integer countTeam = 0;
				while (!findTeam && countTeam < teamList.size()) {
					if (teamList[countTeam].Id == n.Team__c) {
						findTeam = true;
						Team = teamList[countTeam];	
					}
					countTeam++;
				}
				
		        minifeed.add( new MiniFeed__c( 		Type__c='DiscussionNewTopic',
		        									FeedDate__c=System.now(),
		                                           	Team__c=n.Team__c,	        
		                                           	User__c=n.CreatedById,
		                                          	Message__c='created new discussion topic <a href="/apex/DiscussionDetail?id=' + n.Id +'"/>' + n.Subject__c + '</a> in <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + Team.Name + '</a>')); 
		    }
		    insert minifeed;
		    
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 		
}