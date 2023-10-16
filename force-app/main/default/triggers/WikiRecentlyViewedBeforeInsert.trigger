trigger WikiRecentlyViewedBeforeInsert on WikiRecentlyViewed__c (before insert) {


	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			//
			// Need to populate the Team__c field on the comment object
			//
			List<String> wikiPages = new List<String>();
	      	for(WikiRecentlyViewed__c newView : trigger.new){
	        	wikiPages.add(newView.WikiPage__c);
	        }
	        
			Map<Id, WikiPage__c> wikiMap = new Map<Id, WikiPage__c>([select Team__c from WikiPage__c where Id in: wikiPages]);
			
			for(WikiRecentlyViewed__c newView : trigger.new){
	        	newView.Team__c = wikiMap.get(newView.WikiPage__c).Team__c;
	        }			
			
			//
			// Once we have populated the Team field we can do our usual pre insert check list
			//
	        List<String> idsTeam = new List<String>();
	        List<String> queueNames = new List<String>();
	      	for(WikiRecentlyViewed__c newView : trigger.new){
	        	idsTeam.add(newView.team__c);
	        	queueNames.add('Wiki' + newView.team__c);
	        }
	        
	        // Check to see if this is an admin user.  If so they can create in any team 
	        List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:UserInfo.getUserId() limit 1];	
			Boolean isAdmin = false;
		
			if(teamAdmin[0].Profile.PermissionsModifyAllData){
				//Is SysAdmin
				// Might need to do this per author.  What if mutiple authors come through the trigger???
				isAdmin = true;			
			}		
	        
	        Map<Id, TeamProfile__c> profileMap = new Map<Id, TeamProfile__c>();
	        if(!isAdmin){
				// Check to see if the user is in the team and if so then use that Team Profile
				for(TeamMember__c tm: [select Team__c												
										from TeamMember__c 
										where User__c =:UserInfo.getUserId() 
										and Team__c in: idsTeam]) {
					profileMap.put(tm.Team__c, tm.TeamProfile__r);
				}
												 
			
				// If the user is not a membe of the team then we have to go to to the public profile of the team
				// to figure out the permissions.
				for(Team__c t: [select PublicProfile__c
								from Team__c
								where Id in: idsTeam]) {
					if(profileMap.get(t.Id) == null) profileMap.put(t.Id, t.PublicProfile__r);						  	
				}
				
	        }				
	        
	        // Get the owner queue
	        Map<String, Id> queueMap = new Map<String, Id>();
			for(Group g: [select id, Name from Group where name in: queueNames and type = 'Queue' limit 1]) {
				queueMap.put(g.Name, g.Id);
			}
	        
	        // 
	        for(WikiRecentlyViewed__c newView : trigger.new){
	        	
	        	// Check to see if this user can create a wiki page
	        	TeamProfile__c profile = profileMap.get(newView.Team__c);
	        	
	        	if(!isAdmin && profile == null)
	        		newView.addError('Cannot Insert A Wiki View Record. Insufficient Privileges');
	        	
				
				Id queueId = queueMap.get('Wiki' + newView.team__c);
				if(queueId != null)
					newView.OwnerId = queueId;

	        }	
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
	
}