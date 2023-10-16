trigger MainFeedTeamMemberAfterUpdate on TeamMember__c bulk (after update) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
			
			List<String> userIds = new List<String>();
		    List<String> teamIds = new List<String>();
		    List<String> profileIds = new List<String>();
		    for (TeamMember__c iter : Trigger.new) {
		    	userIds.add(iter.User__c);
		    	teamIds.add(iter.Team__c); 
		    	profileIds.add(iter.TeamProfile__c);
		    }
		    
		    Map<Id,User> userMap = new Map<Id,User>();
		    for (User iterUser : [select id, name from User where id in: userIds]) {
		    	userMap.put(iterUser.Id, iterUser);
		    }
		    
		    Map<Id, Team__c> teamMap = new Map<Id, Team__c>();
		    for (Team__c iterTeam : [select id, name from  Team__c where id in: teamIds]) {
		    	teamMap.put(iterTeam.id, iterTeam);
		    } 
		    
		    Map<Id, TeamProfile__c> profileMap = new Map<Id, TeamProfile__c>();
			for (TeamProfile__c iterProfile : [Select Id, Name FROM TeamProfile__c WHERE Id in: profileIds]) {
				profileMap.put(iterProfile.Id, iterProfile);	
			}
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
		    for(Integer i = 0; i < Trigger.old.size(); i++) {
		        TeamMember__c o = Trigger.old[i];
		        TeamMember__c n = Trigger.new[i];
		        
		        Team__c currentTeam = teamMap.get(n.Team__c);
		        User currentUser = userMap.get(n.User__c);
		        // Blurb:
		        if(o.TeamRole__c != n.TeamRole__c){
			        // Modified team Role
			        minifeed.add( new MiniFeed__c( Type__c='TeamEditRole',
		                                           User__c=n.LastModifiedById,
		                                           FeedDate__c=System.now(),
		                                           Team__c=n.Team__c,
		                                           Message__c=' updated <a href="/apex/PeopleProfileDisplay?id=' + n.User__c +'">' + currentUser.Name + '\'s</a> team role to ' + n.TeamRole__c + ' in the <a href="/apex/TeamsRedirect?id=' + n.Team__c + '">' + currentTeam.Name + '</a> team '));
		        } else {
		        	// Modified Team Profile
		        	if(o.TeamProfile__c != n.TeamProfile__c){
		        		
		        		TeamProfile__c TeamProfile = profileMap.get(n.TeamProfile__c);
		        		
			        	minifeed.add( new MiniFeed__c( Type__c='TeamEditProfile',
			                                           User__c=n.LastModifiedById,
			                                           FeedDate__c=System.now(),
		                                           	   Team__c=n.Team__c,
			                                           Message__c=' updated <a href="/apex/PeopleProfileDisplay?id=' + n.User__c +'">' + currentUser.Name + '\'s</a> team profile to ' + TeamProfile.Name + ' in the <a href="/apex/TeamsRedirect?id="' + n.Team__c + '">' + currentTeam.Name + '</a> team '));
		        	}
		        }
		    }
		    insert minifeed;

		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}
}