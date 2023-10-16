trigger MainFeedDiscussionMessage on DiscussionMessage__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			/**
			* This happens after insert
			*/	
		  	List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
			
			List<String> idsTeam = new List<String>();
			List<String> idsTopic = new List<String>();
			for (DiscussionMessage__c iterDM : Trigger.new) {
				idsTeam.add(iterDM.team__c);
				idsTopic.add(iterDM.DiscussionTopic__c);	
			}
			
			List<Team__c> teamList = [select Name, Id from Team__c where Id in: idsTeam];
			
			List<DiscussionTopic__c> topicList = [select Name, Id, MessageCount__c from DiscussionTopic__c where id in: idsTopic];
			
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		
		        DiscussionMessage__c n = Trigger.new[i];
				
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
				
				DiscussionTopic__c Topic;
				Boolean findTopic = false;
				Integer countTopic = 0;
				while (!findTopic && countTopic < topicList.size()) {
					if (topicList[countTopic].Id == n.DiscussionTopic__c) {
						findTopic = true;
						Topic = topicList[countTopic];
					}
					else {
						countTopic++;
					}	
				}
				 
		    	// Blurb:
		    	if(topicList[countTopic].MessageCount__c > 1){
		        	minifeed.add( new MiniFeed__c( Type__c='DiscussionNewReply',
		                                           	User__c=n.CreatedById,
		                                           	FeedDate__c=System.now(),
		                                           	Team__c=n.Team__c,
		                                           	Message__c='replied to discussion topic <a href="/apex/DiscussionDetails?id=' + n.DiscussionTopic__c + '>' + Topic.Name + '</a> in <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + Team.Name + '</a>'));
				
			    }
		    }  
		    insert minifeed;
		     
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}