public class AdminProfileController {
	
	public TeamProfile__c teamProfile;
	public String section;
	
	public Boolean hasMember = false;
	
	public Boolean getHasMember () {
		return hasMember;
	}
	
	public AdminProfileController(){
		TeamUtil.isAdminMemberUser();
		String teamProfileId;
		String clonParameter;
		String teamProfileView;
		teamProfileId = System.currentPageReference().getParameters().get('id');
		clonParameter = System.currentPageReference().getParameters().get('clone');
		teamProfileView = System.currentPageReference().getParameters().get('view');
		String idTeamProf;
		
		if(clonParameter != null){
			idTeamProf = clonParameter;	
			setSection('clone');
		}
		else if(teamProfileId != null){
			idTeamProf = teamProfileId;
			setSection('edit');
		}else if (teamProfileView != null){
			idTeamProf = teamProfileView;
		}else{
			setSection('create');
		}
		if(idTeamProf != null && idTeamProf != ''){
			teamProfile = [SELECT   t.PostWikiComments__c, 
									t.PostDiscussionTopicReplies__c, 
									t.PostBookmarkComments__c, 
									t.PostBlogComments__c, 
									t.Name, 
									t.ManageWikis__c, 
									t.ManageTeams__c, 
									t.ManageProjectTasks__c, 
									t.ManageDiscussionForums__c, 
									t.ManageBookmarks__c, 
									t.ManageBlogs__c, 
									t.Id, 
									t.Description__c, 
									t.CreatedBy.Name, 
									t.CreatedById, 
									T.CreatedDate,
									t.CreateWikiPages__c, 
									t.CreateProjectTasks__c, 
									t.CreateDiscussionTopics__c, 
									t.CreateBookmarks__c,
									t.LastModifiedBy.Name,
									t.LastModifiedById,
									t.LastModifiedDate, 
									t.CreateBlogs__c,
									(select id from TeamMember__r) 
							 From TeamProfile__c t
							 Where t.Id =: idTeamProf];
			if (teamProfile.TeamMember__r.size() > 0) {
				hasMember = true;
			}
			else {
				hasMember = false;
			} 
		}else{
			teamProfile = new TeamProfile__c();	
		}					 
		System.debug('\n\n////////////////////////\n SAVE TEAM PROFILE Has Member Boolean: \n' + hasMember + '\n /////////////////// \n');
		System.debug('\n\n////////////////////////\n SAVE TEAM PROFILE: \n' + teamProfile + '\n /////////////////// \n');
	}
	
	public boolean getIsAClone(){
		String clon = System.currentPageReference().getParameters().get('clone');
		if(clon != null){
			return true;
		}
		return false;
	}
		
	
	public TeamProfile__c getTeamProfile(){
		return teamProfile;
	}
	
	public void setTeamProfile (TeamProfile__c t){
		teamProfile = t;
	}
	
	public boolean getPermissionAuthorApex(){
		User user = [Select u.Profile.Name, u.Profile.PermissionsAuthorApex, u.ProfileId, u.Name, u.Id From User u Where Id =: UserInfo.getUserId()];
		return user.Profile.PermissionsAuthorApex;
	}
	
	public boolean getIsTeamAdminMember(){
		List<User> teamAdmin = [Select id, Profile.PermissionsModifyAllData, ProfileId, Name From User where id =:UserInfo.getUserId() limit 1];                             
        if(getPermissionAuthorApex() && teamAdmin[0].Profile.PermissionsModifyAllData){
        	return true;
        }
        return false;
	}
	
	public String getSection(){
		return section;
	}
	public void setSection(String newSection){
		section = newSection;
	}
	
	public void asignSection(){
		setSection(System.currentPageReference().getParameters().get('section'));
	}
	
	public List<TeamProfile__c> getAllTeamProfiles(){
		List<TeamProfile__c> allTeamProfiles = new List<TeamProfile__c>();
		allTeamProfiles = [Select t.OwnerId, 
								  t.Name, 
								  t.LastModifiedDate, 
								  t.Id, 
								  t.Description__c, 
								  t.CreatedDate 
						   From TeamProfile__c t ];
		return 	allTeamProfiles;
	}			   			   
	
	public boolean getExistName(){
		for(TeamProfile__c t : getAllTeamProfiles()){
			if(t.Name == teamProfile.Name && section == 'clone'){
				return true;
			}
		}	
		return false;
	}					   
	   
						   
	public PageReference saveTeamProfile(){
		if(teamProfile != null){
			if(section == 'edit'){
				update teamProfile;
			}else{
				if(section == 'clone'){
					if(!getExistName()){
						TeamProfile__c clone = new TeamProfile__c();
						clone = teamProfile.clone(false, true);
						insert clone;
					}
				}else if (section == 'create'){
					insert teamProfile;
				}
			}
		}
		
		PageReference pageRef = new PageReference('/apex/AdminProfileList?success='+section);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	*Reasing users to other team profile
	*@void
	*/
	public String oldIdProfile = '';
	
	public String getOldIdProfile () {
		return oldIdProfile;
	}
	
	public void setOldIdProfile (String oldIdProfile) {
		this.oldIdProfile = oldIdProfile;	
	}
	
	public String newIdProfile = '';
	
	public String getNewIdProfile () {
		return newIdProfile;
	}
	
	public void setNewIdProfile (String newIdProfile) {
		this.newIdProfile = newIdProfile;	
	}
	
	public String profileListMode = '';
	
	public String getProfileListMode () {
		return profileListMode;
	}
	
	public void setProfileListMode (String profileListMode) {
		this.profileListMode = profileListMode;	
	}	
	
	public PageReference reAssignUsers (){
		List<TeamMember__c> members = new List<TeamMember__c>();
		if (oldIdProfile != null && newIdProfile != null) {
			members = [select m.Id,m.User__r.Name, m.TeamProfile__c from TeamMember__c m where m.TeamProfile__c =: oldIdProfile];
			for (TeamMember__c m : members){
				m.TeamProfile__c = newIdProfile;
			}
			System.debug('\n\n////////////////////////// SAVE THIS MEMBERS TO UPDATE: ' + members + '\n /////////////////////// \n\n');
			update members;
			List<TeamProfile__c> oldProfile = [select Id, Name from TeamProfile__c where id=:oldIdProfile];
			System.debug('\n\n////////////////////////// SAVE THIS PROFILE TO DELETE: ' + oldProfile + '\n /////////////////////// \n\n');
			delete oldProfile;
		}
		PageReference reAssignPage = new PageReference('/apex/AdminProfileList');
		reAssignPage.setRedirect(true);
		if (profileListMode == 'true') {
			return null;
		}
		else {
			return reAssignPage;
		}
	}

	/**
	*@Remove Team Profile
	*/
	public String idTeamProfileNoMembers = '';
	
	public void setIdTeamProfileNoMembers (String idTeamProfileNoMembers) {
		this.idTeamProfileNoMembers = idTeamProfileNoMembers;
	}
	
	public PageReference removeTeamProfileNoMembers () {
		if (System.currentPageReference().getParameters().get('idRmvTP') != null) {
			idTeamProfileNoMembers = System.currentPageReference().getParameters().get('idRmvTP');
		}
		List<TeamProfile__c> teamProfileToRemove = [select id from TeamProfile__c where id=: idTeamProfileNoMembers];
		delete 	teamProfileToRemove;
		PageReference reAssignPage = new PageReference('/apex/AdminProfileList');
		reAssignPage.setRedirect(true);
		return reAssignPage;	
	}	
}