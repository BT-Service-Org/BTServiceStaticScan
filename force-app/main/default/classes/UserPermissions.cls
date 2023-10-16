public class UserPermissions {

	/* Vars */
	String id;
	String team;
	String objectType;
	String ownerId;
	
	/* Booleans */
	Boolean canCreate = false;
	Boolean canManage = false;
	Boolean canComment = false;
	Boolean canView = true;
	
	public UserPermissions (){
		
	}
	
	/* Getters */
	public String getId () {
		return id;
	}
	
	public String getTeam () {
		return team;
	}
	
	public String getObjectType () {
		return objectType;
	}
	
	public Boolean getCanCreate () {
		return canCreate;
	}
	
	public Boolean getCanManage () {
		return canManage;
	}
	
	public Boolean getCanComment () {
		return canComment;
	}
	
	public Boolean getCanView () {
		return canView;
	}
	
	/* Setters */
	public void setId (String id) {
		this.id = id;
	}
	
 	public void setOwnerId (String ownerId) {
		this.ownerId = ownerId;
	}
	
	public void setTeam (String team) {
		this.team = team;
	}
	
	public void setObjectType (String objectType) {
		this.objectType = objectType;
	}
	
	/**
	* Get permissions for current user
	*@void
	*/
	public void setPermissions () {
		
		try{
			System.debug('\n setPermissions :' + team + '');
			
			List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:id limit 1];
			 
			Boolean isAdmin = false;
			
			if(teamAdmin[0].Profile.PermissionsModifyAllData){
				canManage = true;
				canCreate = true;
				canView = true;
				canComment = true;
				isAdmin = true;
			}
			
			if(!isAdmin){
	
				List<TeamMember__c> members = 	[select TeamProfile__r.PostWikiComments__c, 
														TeamProfile__r.PostDiscussionTopicReplies__c,
														TeamProfile__r.PostBookmarkComments__c,
														TeamProfile__r.PostBlogComments__c,
														TeamProfile__r.ManageWikis__c,
														TeamProfile__r.ManageTeams__c,
														TeamProfile__r.ManageProjectTasks__c,
														TeamProfile__r.ManageDiscussionForums__c,
														TeamProfile__r.ManageBookmarks__c,
														TeamProfile__r.ManageBlogs__c,
														TeamProfile__r.CreateWikiPages__c, 
														TeamProfile__r.CreateProjectTasks__c,
														TeamProfile__r.CreateDiscussionTopics__c,
														TeamProfile__r.CreateBookmarks__c,
														TeamProfile__r.CreateBlogs__c
												 from TeamMember__c 
												 where User__c =:id 
												 and Team__c=:Team 
												 limit 1];
												 
				TeamProfile__c profile = null;
				
				// If the user is a member of the team we should use the profile assigned to that user
				if (members.size() > 0) {
					profile = members[0].TeamProfile__r;
				
				// If the user is not a membe of the team then we have to go to to the public profile of the team
				// to figure out the permissions.
				} else {
					
					List<Team__c> team = [SELECT PublicProfile__c, 
												 PublicProfile__r.PostWikiComments__c, 
												 PublicProfile__r.PostDiscussionTopicReplies__c,
												 PublicProfile__r.PostBookmarkComments__c,
												 PublicProfile__r.PostBlogComments__c,
												 PublicProfile__r.ManageWikis__c,
												 PublicProfile__r.ManageTeams__c,
												 PublicProfile__r.ManageProjectTasks__c,
												 PublicProfile__r.ManageDiscussionForums__c,
												 PublicProfile__r.ManageBookmarks__c,
												 PublicProfile__r.ManageBlogs__c,
												 PublicProfile__r.CreateWikiPages__c, 
												 PublicProfile__r.CreateProjectTasks__c,
												 PublicProfile__r.CreateDiscussionTopics__c,
												 PublicProfile__r.CreateBookmarks__c,
												 PublicProfile__r.CreateBlogs__c
										  FROM Team__c
										  WHERE Id =: Team];
									
					if(team.size() > 0) profile = team[0].PublicProfile__r;
				}				
						
				System.debug('\n setPermissions profile:' + profile + '');
																
				if (profile != null) {
					
					/*		WIKI		*/
					if (objectType == 'Wiki') {
						
						if(profile.CreateWikiPages__c) 	canCreate = true;
						
						if(profile.PostWikiComments__c) canComment = true;
						
						if(profile.ManageWikis__c) 		{ canManage = true; canCreate = true; canComment = true; }
												
					}
					
					/*		PROJECT		*/
					if (objectType == 'Project') {
						
						if(profile.CreateProjectTasks__c) 	canCreate = true;	
						
						if (profile.ManageProjectTasks__c)	{ canManage = true; canCreate = true; }

					}
					
					/*		DISCUSSION		*/
					if (objectType == 'Discussion') {
						
						if(profile.CreateDiscussionTopics__c) 		canCreate = true;
						
						if(profile.PostDiscussionTopicReplies__c) 	canComment = true;
						
						if (profile.ManageDiscussionForums__c) 		{ canManage = true;	canCreate = true; canComment = true; }					
														
					}			
						
					/*     TEAM   */
					if(objectType == 'Team') {
						
						if(profile.ManageTeams__c) canManage = true;
						
					}								
				}
			}
			System.debug('\n\n/////////////////////// \n SAVE THIS: \n ownerId: ' + ownerId + '\n id: ' + id + '\n/////////////\n\n');
			if(ownerId == id) canManage = true;  // Shouldnt this be called user UserId?
			System.debug('\n\n/////////////////////// \n SAVE THIS: \n canManage: ' + canManage + '\n/////////////\n\n');	
		}catch(Exception e){
			throw e;
		}
	}
}