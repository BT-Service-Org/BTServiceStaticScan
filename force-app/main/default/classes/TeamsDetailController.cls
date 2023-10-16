public with sharing class TeamsDetailController {
	
	Team__c teamspace = new Team__c();
	 
	//Bookmarks variables 
	Bookmark__c bookmark;
    boolean noImage; 
    boolean emailTeamspace;
    String  error = '';
    boolean showError = false; 
	
	String teamIdParam = System.currentPageReference().getParameters().get('id');
	
	public void setTeamIdParam (String idTeam){
		teamIdParam = idTeam;	
	}
	
	public String USERID =  UserInfo.getUserId();
	
    /* ---------------------------- */
   	/*   	 SHARING RULES 			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissionsWiki = new UserPermissions();
	public UserPermissions userPermissionsTeam = new UserPermissions();
	
	public void genPermissions () {
		userPermissionsWiki.setId(UserInfo.getUserId());
		userPermissionsWiki.setTeam(teamIdParam);
		userPermissionsWiki.setObjectType('Wiki');
		userPermissionsWiki.setPermissions();
		
		userPermissionsTeam.setId(UserInfo.getUserId());
		userPermissionsTeam.setTeam(teamIdParam);
		userPermissionsTeam.setObjectType('Team');
		userPermissionsTeam.setPermissions();					
	}

	public UserPermissions getUserPermissionsWiki () {
		return userPermissionsWiki;
	}	
	/* ---------------------------- */		
	
	
	/**
	* @return String teamIdParam The Id of the team
	*/
	public String getTeamIdParam(){
		return teamIdParam;
	}
	/**
	* Boolean to determine if show buttons.
	*/
	Boolean teamIsOpen = false;
	
	public Boolean getTeamIsOpen(){
		return teamIsOpen;
	}
	
		
	public TeamsDetailController(){
		if(teamIdParam != null)
			getTeamDetail();		
		genPermissions();
	}
	
	public void getTeamDetail(){
		try {
			teamspace = [Select  t.SystemModstamp, 
							t.OwnerId, t.Name,						
							t.LastModifiedDate,
							t.LastModifiedById, 
							t.NewMemberProfile__c,
							t.PublicProfile__c,
							t.IsDeleted, 
							t.Id, 
							t.Description__c, 
							t.CreatedDate, 
							t.CreatedById
							From Team__c t 
							where id =: teamIdParam];
			teamIsOpen = showJoinEvent();
		} catch(Exception e ){
			throw e;
		}	
	}
	
	/**
	* Show join event
	*@return Boolean
	*/
	public Boolean showJoinEvent (){
		Boolean canShow = false;
		List<TeamMember__c> members = [select Id from TeamMember__c where User__c =: UserInfo.getUserId() and Team__c =: teamspace.Id limit 1];
		if(members.size() == 0){
			if(teamspace.PublicProfile__c != null && teamspace.NewMemberProfile__c != null){
				canShow = true;
			} else if (userPermissionsTeam.getCanManage()){
				canShow = true;
			}		
		}else{
			canShow = false;
		}
		return canShow;
	}
	
	/**
	* Perform the addition to the team
	*/	
	public boolean showJoinTeamMessage = false;
	
	/**
	* assignShowJoinTeamMessage()
	*@void
	*/
	public void assignShowJoinTeamMessage () {
		String joinedTeamParam = System.currentPageReference().getParameters().get('j');
		if(joinedTeamParam == 'true'){
			showJoinTeamMessage =  true;
		} else {
			showJoinTeamMessage =  false;
		}
	}
	
	public boolean getShowJoinTeamMessage(){
		return showJoinTeamMessage;
	}
	
	
	public void joinTeam(){
		 
		 TeamMember__c newUserJoin = new TeamMember__c();
		 if(teamspace != null ){
		 	
			 newUserJoin.User__c = USERID;
			 newUserJoin.Name = UserInfo.getName();
			 newUserJoin.Team__c = teamspace.Id;
			 newUserJoin.TeamProfile__c = teamspace.NewMemberProfile__c;		 
			 teamIsOpen = false;
			 showJoinTeamMessage = true;
			 
			 insert newUserJoin;
		 }
	}
	
	
	/**
	* Perform the remove from the team
	*/		
	public void leaveTeam(){
		 
		 TeamMember__c userRow = new TeamMember__c();
		
		 try {
		 	userRow = [Select Id, User__c, Team__c from TeamMember__c where User__c =: USERID and Team__c =: teamspace.Id ];
		 	
		 } catch(Exception e){ }
		 		 
		 teamIsOpen = true;
		 showJoinTeamMessage = false;
		
		 delete userRow;
		 
	}
	
	
	        
	/**
	* Get Teamspace
	*@return Team__c
	*/
	public Team__c getTeamspace() {
         teamspace = [select name, description__c, NewMemberProfile__c, TeamType__r.Name, TeamType__r.Id from Team__c
                     where id=: teamIdParam];
         if(teamspace == null) {
         	return null;
         }else {
    		return teamspace;
         }
    }
    
    /**
    * Get Teamspace image
    *@return String
    */
    public String getTeamspaceImage() {
    	/*List<Attachment> attach = [SELECT Id 
        									 FROM Attachment 
        									 WHERE ParentId =:System.currentPageReference().getParameters().get('id')];
        	if(attach.size() == 0) return '';					
        		return '/servlet/servlet.FileDownload?file=' + attach[0].Id;*/
        List<Team__c> teamAvatar = [select Picture__c
        								from Team__c
        								where Id =:System.currentPageReference().getParameters().get('id')];
        if(teamAvatar.size() == 0) return '';
        return '/servlet/servlet.FileDownload?file=' + teamAvatar[0].Picture__c;
    }  
    
 
   	/**
   	* Refresh wiki list for widgets
   	*@void
   	*/
   	public void refreshWikis () {
    	System.debug('\n //////////////////// \n REFRESH THE WIKIS \n ////////////////// \n');
   	}
  
}