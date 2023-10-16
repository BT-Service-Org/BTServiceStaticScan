public with sharing class TeamsMyTeamsWidgetController {

    List<Teams> teams = new List<Teams>();
    
	public TeamsMyTeamsWidgetController(){
		getOwnTeams();
	}
    
   	public List<Teams> getTeams(){
    	return teams;
    }
    
    /*
	*@void
    */    
    public void getOwnTeams(){
    	List<TeamMember__c> members = new List<TeamMember__c>();
    	members  = [Select 
    						Team__r.Id, 
    						Team__r.Name,
	    					Team__r.Description__c, 
	    					TeamProfile__r.ManageTeams__c, 
	    					TeamProfile__r.Name,
	    					//avatar
	    					Team__r.Picture__c, 
	    					Team__r.CreatedDate,
	    					User__c	    					
	                From TeamMember__c s
    				where User__c =: UserInfo.getUserId()
    				order by s.CreatedDate desc
    				limit 15
    			];
    	if(members.size() > 0){
	    	for(TeamMember__c m : members){
	    		if(m.Team__r.Id != null)
	    			teams.add(new Teams(m));	
	    	}
    	}
    }
    
   /**
   *@class
   */
   public class Teams{
    	
    	public TeamMember__c teamMember = null;
    	public String picture = '';
    	
    	public Teams(TeamMember__c m){
    		teamMember = m;
    		getTeamPicture();
    	}
    	
    	public TeamMember__c getTeamMember(){
    		return teamMember;
    	}
    	
    	public String getPicture(){
    		return picture;
    	}
    	
    	public void getTeamPicture(){
    		if(teamMember.Team__r.Picture__c != null)
    			picture = '/servlet/servlet.FileDownload?file=' + teamMember.Team__r.Picture__c;
    	}	        	
    }
    
    
    /* ---------------------------- */
   	/*       	 ORDER BY		    */
   	/* ---------------------------- */
	public Boolean sortByDesc = false;
	
	public String sortBy = 'PostedDate__c';
	
	public void setSortBy(String s){
		sortBy = s;
	}
	
	public Boolean getSortByDesc () {
		return !sortByDesc;
	}
	
	//columna tablas para img flecha
	
	public String getSortBy () {
		String sbCol = '';
		if (sortBy == null || sortBy == 'Team__r.Name') {
			sbCol = 'teamName';	
		}
		if (sortBy == 'TeamProfile__r.Name') {
			sbCol = 'teamProfile';	
		}	
		return sbCol; 
	}

	/*
	 * This is a temporary method to cover us until dynamic apex is back.  This will use hard coded
	 * SOQL statements in place of the dynamic statements
	 */
	public void sortList () {
		List<Teams> teamsList = new List<Teams>();
		
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		
		if(System.currentPageReference().getParameters().get('sb') != null)
			sortBy = System.currentPageReference().getParameters().get('sb');
		
		List<TeamMember__c> teamsResultList = new List<TeamMember__c>();
		
		if (sortByDesc) {
			if (sortBy == 'Team__r.Name') {
				teamsResultList = [Select Team__r.Id, 
										  Team__r.Name, 
										  Team__r.Description__c,
										  Team__r.Picture__c, 
										  TeamProfile__r.ManageTeams__c, 
										  TeamProfile__r.Name, 
										  Team__r.CreatedDate, 
										  User__c From TeamMember__c d	
									where User__c =: UserInfo.getUserId()
									order by Team__r.Name desc];	
			}
			if (sortBy == 'TeamProfile__r.Name') {
				teamsResultList = [Select Team__r.Id, 
										  Team__r.Name, 
										  Team__r.Description__c,
										  Team__r.Picture__c, 
										  TeamProfile__r.ManageTeams__c, 
										  TeamProfile__r.Name, 
										  Team__r.CreatedDate, 
										  User__c From TeamMember__c d	
									where User__c =: UserInfo.getUserId()
									order by TeamProfile__r.Name desc];				
			}		
		} else {
			if (sortBy == 'Team__r.Name') {
				teamsResultList = [Select Team__r.Id, 
										  Team__r.Name, 
										  Team__r.Description__c,
										  Team__r.Picture__c, 
										  TeamProfile__r.ManageTeams__c, 
										  TeamProfile__r.Name, 
										  Team__r.CreatedDate, 
										  User__c From TeamMember__c d	
									where User__c =: UserInfo.getUserId()
									order by Team__r.Name];					
			}
			if (sortBy == 'TeamProfile__r.Name') {
				teamsResultList = [Select Team__r.Id, 
										  Team__r.Name, 
										  Team__r.Description__c,
										  Team__r.Picture__c, 
										  TeamProfile__r.ManageTeams__c, 
										  TeamProfile__r.Name, 
										  Team__r.CreatedDate, 
										  User__c From TeamMember__c d	
									where User__c =: UserInfo.getUserId()
									order by TeamProfile__r.Name];				
			}					
		}
		
		for (TeamMember__c t: teamsResultList) {
			Teams teamItem = new Teams(t);
			teamsList.add(teamItem);
		}
		teams = teamsList;	
	}   

	/*
	 * We have to remove all elements of dynamic apex in order to put this application in the
	 * 62 org.  This code will be added back in once dynamic apex is released GA
	 * 		
	public void sortList () {
		List<Teams> teamsList = new List<Teams>();
		
		if (sortBy == System.currentPageReference().getParameters().get('sb')) {
			sortByDesc = !sortByDesc;
		}
		else {
			sortByDesc = false;
		}
		sortBy = System.currentPageReference().getParameters().get('sb');
		List<TeamMember__c> teamsResultList = new List<TeamMember__c>();
		
		String queryStr;
				
					    			
		queryStr = 'Select Team__r.Id, Team__r.Name, Team__r.Description__c, TeamProfile__r.ManageTeams__c, TeamProfile__r.Name, Team__r.CreatedDate, User__c From TeamMember__c d	where User__c = \'' + UserInfo.getUserId() + '\' order by ' + sortBy;
		
		if (sortByDesc) {
			queryStr += ' desc';
		}
		
		//Query
		
		teamsResultList = Database.query(queryStr); 
		
		for (TeamMember__c t: teamsResultList) {
			Teams teamItem = new Teams(t);
			teamsList.add(teamItem);
		}
		teams = teamsList;	
	}*/        
}