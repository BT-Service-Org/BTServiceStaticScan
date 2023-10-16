trigger MainFeedTeamMemberAfterInsert on TeamMember__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    
		    List<String> userIds = new List<String>();
		    List<String> teamIds = new List<String>();
		    for (TeamMember__c iter : Trigger.new) {
		    	userIds.add(iter.User__c);
		    	teamIds.add(iter.Team__c); 
		    }
		    
		    Map<Id,User> userMap = new Map<Id,User>();
		    for (User iterUser : [select id, name from User where id in: userIds]) {
		    	userMap.put(iterUser.Id, iterUser);
		    }
		    
		    Map<Id, Team__c> teamMap = new Map<Id, Team__c>();
		    for (Team__c iterTeam : [select id, name from  Team__c where id in: teamIds]) {
		    	teamMap.put(iterTeam.id, iterTeam);
		    }  
		    
		    for(Integer i = 0; i < Trigger.new.size(); i++) {
		        TeamMember__c n = Trigger.new[i];  
				Team__c currentTeam = teamMap.get(n.Team__c);
				// User Added by other user
				if(n.CreatedById != n.User__c){
		        	// Blurb:
		        	User currentUser = userMap.get(n.User__c);
		        	minifeed.add( new MiniFeed__c( Type__c='TeamMemberAdd',
		                                           	User__c=n.CreatedById,
		                                           	FeedDate__c=System.now(),
		                                           	Team__c = n.Team__c,
		                                           	Message__c=' added '+ currentUser.Name + ' to the team <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + currentTeam.Name + '</a>' ));
				} else {
					// User joined
		        	minifeed.add( new MiniFeed__c( Type__c='TeamMemberJoin',
		        									FeedDate__c=System.now(),
		                                           	Team__c=n.Team__c,
	                                   				User__c=n.User__c,
	                                   				Message__c=' joined the team <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + currentTeam.Name + '</a>' ));
				}
		    }
		    insert minifeed;

		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}
}