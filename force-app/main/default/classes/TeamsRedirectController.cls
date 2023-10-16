public class TeamsRedirectController {
	
	public String teamId = System.currentPageReference().getParameters().get('id');
	
	/**
	*@param String s
	*/
	public void setTeamId(String s){
		teamId = s;
	}
	
	Team__c team = new Team__c();	
	TeamType__c teamtype = new TeamType__c();
	
	public TeamsRedirectController() {
		if(teamId != null)
			getTeam();
	}
	
	/**
	* Get Team
	*@void
	*/
	public void getTeam(){
		team = [select TeamType__c from Team__c where Id =: teamId];
		if(team != null)
			teamtype = [select Id from TeamType__c where Id =: team.TeamType__c];			
	}
	
	/**
	*@return PageReference
	*/
	public PageReference redirect() {
		if(team.TeamType__c == null) 
			return System.currentPageReference();
		String pageurl = '/apex/TeamsDetail' + teamtype.Id + '?id=' + teamId;   		  
		System.debug('pageurl = ' + pageurl );
		PageReference pr = new PageReference(pageurl);  
		pr.setRedirect(true);     					 
		return pr;
	}

}