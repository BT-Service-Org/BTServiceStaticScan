public class AdminTeamTypeListController {

	
	List<TeamTypes> types;
	
	public AdminTeamTypeListController(){
		TeamUtil.isAdminMemberUser();
		getTeamTypes ();
	}
	
	public void getTeamTypes(){
		types = new List<TeamTypes>();
		List<TeamType__c> teamTypeList = new List<TeamType__c>(); 
		teamTypeList = [select 	t.Id, 
								t.CreatedBy.Name, 
								t.CreatedBy.Id, 
								t.CreatedDate, 
								t.Name, 
								t.PageName__c, 
								t.IsActive__c
						from TeamType__c t order by t.Name];	
		
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
		String createdById = null;
		String createdBy = null;
		Integer teams = 0;
		Boolean hasTeams = true;
		
		/**
		*@param TeamType__c
		*/
		public TeamTypes(TeamType__c teamType){
			this.teamType = teamType;
			this.createdDate = this.teamType.CreatedDate.format('MMMM dd, yyyy HH:mm aa');
			this.getCreatedById();
			this.getCreatedBy();
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
		public String getCreatedById (){
			return createdById;
		}
		
		/**
		*@return String
		*/		
		public String getCreatedBy (){
			return createdBy;
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
		public void getNumberOfTeams(){
			this.teams = [select count() from Team__c t where t.TeamType__c =: teamType.Id];
			if(this.teams == 0)
				this.hasTeams = false;
		}
	

	}

}