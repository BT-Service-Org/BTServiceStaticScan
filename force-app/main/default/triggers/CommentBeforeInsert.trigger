trigger CommentBeforeInsert on Comment__c (before insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			//
			// Need to populate the Team__c field on the comment object
			//
			List<String> wikiPages = new List<String>();
	      	for(Comment__c newComment : trigger.new){
	        	wikiPages.add(newComment.ParentWikiPage__c );
	        }
	        
			Map<Id, WikiPage__c> wikiMap = new Map<Id, WikiPage__c>([select Team__c from WikiPage__c where Id in: wikiPages]);
			
			for(Comment__c newComment : trigger.new){
	        	newComment.Team__c = wikiMap.get(newComment.ParentWikiPage__c ).Team__c;
	        }			
			
			//
			// Once we have populated the Team field we can do our usual pre insert check list
			//
	        List<String> idsTeam = new List<String>();
	        List<String> queueNames = new List<String>();
	      	for(Comment__c newComment : trigger.new){
	        	idsTeam.add(newComment.team__c);
	        	queueNames.add('Wiki' + newComment.team__c);
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
				for(TeamMember__c tm: [select Team__c,												
											  TeamProfile__r.PostWikiComments__c ,									
											  TeamProfile__r.ManageWikis__c,
											  TeamProfile__r.CreateWikiPages__c													
										from TeamMember__c 
										where User__c =:UserInfo.getUserId() 
										and Team__c in: idsTeam]) {
					profileMap.put(tm.Team__c, tm.TeamProfile__r);
				}
												 
			
				// If the user is not a membe of the team then we have to go to to the public profile of the team
				// to figure out the permissions.
				for(Team__c t: [select PublicProfile__c, 
									   PublicProfile__r.PostWikiComments__c,
									   PublicProfile__r.ManageWikis__c,
									   PublicProfile__r.CreateWikiPages__c
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
	        for(Comment__c newComment : trigger.new){
	        	
	        	// Check to see if this user can create a wiki page
	        	TeamProfile__c profile = profileMap.get(newComment.Team__c);
	        	
	        	if(!isAdmin && !profile.PostWikiComments__c && !profile.ManageWikis__c && !profile.CreateWikiPages__c)
	        		newComment.addError('Cannot Insert A New Comment. Insufficient Privileges');
	        	
				
				Id queueId = queueMap.get('Wiki' + newComment.team__c);
				if(queueId != null)
					newComment.OwnerId = queueId;

	        }	
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 
}