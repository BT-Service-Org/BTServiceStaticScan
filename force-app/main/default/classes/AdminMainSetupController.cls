public class AdminMainSetupController {
	
	List<TeamTypes> types;
	List<TeamProfile> profiles;
	String oldIdProfile = null;
	String newIdProfile = null;	
	
	public AdminMainSetupController(){
		TeamUtil.isAdminMemberUser();
		getTeamTypes ();
		getTeamProfiles();
	}
	
	//********************************************************
	//***************** Popular Team Types *****************
	//********************************************************
		
	public void getTeamTypes(){
		types = new List<TeamTypes>();
		List<TeamType__c> teamTypeList = new List<TeamType__c>(); 
		
		teamTypeList = [select t.Id, t.CreatedById, t.CreatedDate, 
						t.Name, t.PageName__c, t.IsActive__c
						from TeamType__c t order by t.CreatedDate desc LIMIT 5];
		
		for (TeamType__c teamType : teamTypeList){
			types.add (new TeamTypes(teamType));
		}	
	}
	
	
	/**
	*@return List<TeamTypes>
	*/
	public List<TeamTypes> getTypes () {
		return types;
	}
	
	
	public class TeamTypes {
		
		TeamType__c teamType = null;
		String createdDate = null;
		User creator = null;
		Integer teams = 0;
		Boolean hasTeams = true;
		
		/**
		*@param TeamType__c
		*/
		public TeamTypes(TeamType__c teamType){
			this.teamType = teamType;
			this.createdDate = this.teamType.CreatedDate.format('MMMM dd, yyyy HH:mm aa');
			this.getCreatorName();
			this.getNumberOfTeams();
		}
		
		/**
		*@return TeamType__c t
		*/
		public TeamType__c getTeamType (){
			return teamType;
		}
		
		/**
		*@return String
		*/		
		public User getCreator (){
			return creator;
		}
		
		/**
		*@return String
		*/
		public String getCreatedDate (){
			return createdDate;
		}
		
		/**
		*@return Integer
		*/
		public Integer getTeams(){
			return teams;
		}
		
		/**
		*@return Boolean 
		*/	
		public Boolean getHasTeams(){
			return hasTeams;
		}

		/**
		*@void
		*/
		public void getCreatorName (){
			User user = null;
			user = [select u.Name, u.Id from User u where u.Id =: teamType.CreatedById];
			this.creator = user; 
		}
		
		/**
		*@void
		*/
		public void getNumberOfTeams(){
			this.teams = [select count() from Team__c t where t.TeamType__c =: teamType.Id];
			if(this.teams == 0)
				this.hasTeams = false;
		}
	}
	
	//********************************************************
	//***************** Team Profiles *****************
	//********************************************************

	
	/**
	*@param String id
	*/
	public void setOldIdProfile (String id){
		oldIdProfile = id;
	}
	
	/**
	*@return String id
	*/
	public String getOldIdProfile (){
		return oldIdProfile;
	}
	
	/**
	*@param String id
	*/
	public void setNewIdProfile (String id){
		newIdProfile = id;
	}
	
	/**
	*@return String id
	*/
	public String getNewIdProfile (){
		return newIdProfile;
	}			
	
	/**
	*@void
	*/
	public void getTeamProfiles(){
		profiles = new List<TeamProfile>();
		List<TeamProfile__c> teamProfileList = new List<TeamProfile__c>(); 
		teamProfileList = [select t.Id, t.CreatedById, t.CreatedDate, 
						t.Name from TeamProfile__c t order by t.CreatedDate desc LIMIT 5];
		
		for (TeamProfile__c teamProfile : teamProfileList){
			profiles.add (new TeamProfile(teamProfile));
		}	
	}
	
	
	/**
	*@return List<TeamTypes>
	*/
	public List<TeamProfile> getProfiles () {
		return profiles;
	}
	
	/**
	*Reasing users to other team profile
	*@void
	*/
	public void reAssignUsers (){
		List<TeamMember__c> members = new List<TeamMember__c>();
		members = [select m.Id, m.TeamProfile__c from TeamMember__c m where m.TeamProfile__c =: oldIdProfile];
		for (TeamMember__c m : members){
			m.TeamProfile__c = newIdProfile;
		}
		update members;
	}
	
	
	
	/**
	*@class::TeamProfile
	*/
	public class TeamProfile {
		
		public TeamProfile__c teamProfile = null;
		String createdDate = null;
		User creator = null;
		
		/**
		*@param TeamProfile__c
		*/
		public TeamProfile(TeamProfile__c profile){
			this.teamProfile = profile;
			this.createdDate = this.teamProfile.CreatedDate.format('MMMM dd, yyyy HH:mm aa');
			this.getCreatorName();
		}
		
		/**
		*@return TeamProfile__c t
		*/
		public TeamProfile__c getTeamProfile (){
			return teamProfile;
		}
		
		/**
		*@return String
		*/		
		public User getCreator (){
			return creator;
		}
		
		/**
		*@return String
		*/
		public String getCreatedDate (){
			return createdDate;
		}
		
		/**
		*@void
		*/
		public void getCreatorName (){
			User user = null;
			user = [select u.Name, u.Id from User u where u.Id =: teamProfile.CreatedById];
			this.creator = user; 
		}	
	}
	
	
	public void getAll(){
		getTeamProfiles();
		getTeamTypes();
	}
	
}