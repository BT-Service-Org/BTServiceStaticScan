public without sharing class TeamDetailsWidgetController {
	
	// Get Team Id Attribute
	String team;
	
	// Setter method for Team Id variable
	public void setTeam(String tID) {
		team = tID;
	}
	
	public String getTeam(){
		return team;
	}
	
	// Active user ID
	public String USERID =  UserInfo.getUserId();
	
	public String getCurrentUser(){
		return USERID;
	}
	
	Team__c teamspace = new Team__c();
	
	public TeamDetailsWidgetController(){}

    /* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	public void genPermissions() {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(team);
		userPermissions.setObjectType('Team');
		userPermissions.setPermissions();		
	}

	public UserPermissions getUserPermissions () {
		return userPermissions;
	}	
	/* ---------------------------- */			
		
		        
	public Team__c getTeamspace() {
		try {
			teamspace = [Select  t.SystemModstamp, 
									t.OwnerId, t.Name,						
									t.LastModifiedDate,
									t.LastModifiedById, 
									t.IsDeleted,
									t.Id, 
									t.Description__c,
									t.Picture__c, 
									t.CreatedDate, 
									t.CreatedById 
									From Team__c t 
									where id =: team];
			genPermissions();									
		} catch(Exception e){
			
		}		
					
    	return teamspace;
    }
    
     /**
    * Look if the user is a team member
    */    
    public boolean getIsTeamMember(){
    	List<TeamMember__c> tmember = new List<TeamMember__c>();
    	try{
    		tmember = [Select TeamProfile__r.Name, TeamProfile__c From TeamMember__c where User__c =: USERID and Team__c =: team];
    	} catch(Exception e){}
    	if(tmember.size() > 0){	    	
	    	return true;	    	
    	}else {
    		return false;
    	}   	
    }
    
    /**
    * Send id of teammember (if any)
    */
    public String getTeamMemberId(){
    	
    	List<TeamMember__c> tmember = new List<TeamMember__c>();
    	
    	try{
    		tmember = [Select TeamProfile__r.Name, TeamProfile__c From TeamMember__c where User__c =: USERID and Team__c =: team];
    	} catch(Exception e){}
    	
    	if(tmember.size() > 0){	    	
	    	return tmember[0].Id;	    	
    	}else {
    		return 'no';
    	}    	 
    }
    
    
    /**
    * Look if the user is the team admin
    */    
    public boolean getIsTeamAdmin(){
    	
    	TeamMember__c tmember = new TeamMember__c();
    	
    	try{
    		tmember = [Select TeamProfile__r.Name, TeamProfile__c From TeamMember__c where User__c =: USERID and Team__c =: team];
    	} catch(Exception e){}
    	
    	if(tmember != null){
	    	if(tmember.TeamProfile__r.Name == 'Team Administrator'){
	    		return true;
	    	} else {
	    		return false;
	    	}
    	}else {
    		return false;
    	}   	
    	
    }
    
    /**
    * Get The list of admins to this team
    */
    public String getTeamAdmins(){
    	
    	List<TeamMember__c> tmemberList = new List<TeamMember__c>();
    	
    	try {
    		tmemberList = [Select User__r.Name, User__c From TeamMember__c where TeamProfile__r.Name = 'Team Administrator' and Team__c =: team];
    	} catch (Exception e){
    		System.Debug('\n /////////////////////////// \n Error:!' + e );
    	}
    	
    	String teamMemberList = ' ';
    	
    	if(tmemberList.size() > 0 ){ 
	    	
	    	
	    	for(TeamMember__c tm: tmemberList){
	    		teamMemberList += '<a href="PeopleProfileDisplay?id=' + tm.User__c + '" >'+ tm.User__r.Name +'</a><br />';    	
	    	}     	
    	}
    	
    	return teamMemberList;
	    
    }
    
    /**
    * Get The count of members at the team
    */
    public Integer getTeamCount(){
    	
    	List<TeamMember__c> tmemberList = new List<TeamMember__c>();
    	
    	try {
    		tmemberList = [Select Id From TeamMember__c where Team__c =: team];
    	} catch (Exception e){
    		System.Debug('\n /////////////////////////// \n Error:!' + e );
    	}
    	
    	return tmemberList.size();
	    
    }
    
    
    
    public String getTeamspaceImage() {
    	if(teamspace.Picture__c == null) return '';
    		return '/servlet/servlet.FileDownload?file=' + teamspace.Picture__c;   		
    }
    
    /**
    * Leave a Team
    *@void
    */
    public void leaveTeam (){
    	try{
	    	TeamMember__c member = [select Id from TeamMember__c where User__c =: UserInfo.getUserId() and Team__c =: teamspace.Id];
	    	delete member;
    	}catch(Exception e){
    		throw e;
    	}
    }
    
	
}