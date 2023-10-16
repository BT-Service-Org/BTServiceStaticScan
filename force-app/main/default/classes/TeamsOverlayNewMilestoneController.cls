public class TeamsOverlayNewMilestoneController {
	
	ProjectTask__c theNewTask = new ProjectTask__c();
   	
   	public String TEAMID = System.currentPageReference().getParameters().get('id');
   	
   	public String getCurrentTeamId(){
   		return TEAMID;
   	}
   	
   	public Project2__c currentProject = null;
   	
   	//public String name {get; set;}
   	
    /**
    *@return ProjectTask__c
    */
    public ProjectTask__c newProyect = new ProjectTask__c();
    public ProjectTask__c getTask(){
    	return newProyect;
    }
    
     /**
    *@return TeamMember__c
    */
    public TeamMember__c teamMember = new TeamMember__c();
    public TeamMember__c getTeamMember(){
    	return teamMember;
    }
    
    
    public List<SelectOption> getTeamMembers() {
    	List<TeamMember__c> teamMembers = new List<TeamMember__c>();  
  	 	List<SelectOption> options = new List<SelectOption>();
  	 	if(TEAMID != null){
	  	 	teamMembers = [Select t.Team__c, t.User__r.Name, t.Name, t.User__c, t.Id From TeamMember__c t where t.Team__c =: TEAMID];  
	  	 	options.add(new SelectOption('-1', 'Choose a team Member'));
	  	 	for(TeamMember__c c: teamMembers) {
	    		options.add(new SelectOption(c.User__c, c.User__r.Name)); 
	 		}
  	 	}
  	 	return options;
   	}
    
    public TeamsOverlayNewMilestoneController(){
    	getCurrentProject();
    	genPermissions();	
	}
	
	public void getCurrentProject(){
		if(TEAMID != null)
			currentProject = [select Id from Project2__c where Team__c =: TEAMID limit 1];
	}
	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = null;
	
	public void genPermissions () {
		userPermissions = new UserPermissions();
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(TEAMID);
		userPermissions.setObjectType('Project');
		userPermissions.setPermissions();		
	}

	/* ---------------------------- */	
	
	
	/* ---------------------------- */
   	/*   	  INSERT MILESTONE		*/
   	/* ---------------------------- */  
   	
   	public void insertMilestone () 
   	{ 
   		if(!userPermissions.getCanCreate())
        		throw new CustomException('Insufficient Privileges');
        		
   		ProjectTask__c myTask = new ProjectTask__c();
		
		myTask.Milestone__c = true;
		myTask.Team__c = TEAMID;
		myTask.Name = newProyect.name;
		myTask.StartDate__c = newProyect.EndDate__c;
		myTask.EndDate__c = newProyect.EndDate__c;
		myTask.Percent_Completed__c = 0;
		myTask.Project__c = currentProject.Id;
  		insert myTask; 
  		
  		
  		
  		ProjectAssignee__c Assign = new ProjectAssignee__c();
		Assign.User__c = teamMember.User__c;
		Assign.ProjectTask__c = myTask.Id;
		insert Assign;
   		
 		
   	}
}