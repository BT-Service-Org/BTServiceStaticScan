trigger MainFeedTeamMemberAfterDelete on TeamMember__c bulk (after delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
			
			List<String> teamIds = new List<String>();
		    for (TeamMember__c iter : Trigger.old) {
		    	teamIds.add(iter.Team__c); 
		    }
		    Map<Id, Team__c> teamMap = new Map<Id, Team__c>();
		    for (Team__c iterTeam : [select id, name from  Team__c where id in: teamIds]) {
		    	teamMap.put(iterTeam.id, iterTeam);
		    } 
			
			List<MiniFeed__c> minifeed = new List<MiniFeed__c>();
	   		for(Integer i = 0; i < Trigger.old.size(); i++) {
		        TeamMember__c o = Trigger.old[i];
		        
		        Team__c currentTeam = teamMap.get(o.Team__c);
		        // Blurb:
		        minifeed.add( new MiniFeed__c( Type__c='TeamMemberLeave',
		                                           User__c= o.User__c,
		                                           FeedDate__c= System.now(),
		                                           Team__c= o.Team__c,
		                                           Message__c=' left the team <a href="/apex/TeamsRedirect?id=' + o.Team__c + '">' + currentTeam.Name + '</a>' ));
	   		}
	   		insert minifeed;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
}