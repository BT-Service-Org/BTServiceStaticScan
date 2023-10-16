@IsTest private class TeamsMyTeamsWidgetTest {
	public static testMethod void testTeam() {
  		try{
  			TeamsMyTeamsWidgetController team = new TeamsMyTeamsWidgetController();
  			team.getOwnTeams();
  			TeamsMyTeamsWidgetController.Teams teams = new TeamsMyTeamsWidgetController.Teams(new TeamMember__c());
  			String sortBy = team.getSortBy();
  			String p = teams.getPicture();
  			Boolean sortDesc = team.getSortByDesc();
  			TeamMember__c member = teams.getTeamMember();
  			
  			team.setSortBy('Team__r.Name');
  			team.sortList();

  			team.setSortBy('TeamProfile__r.Name');
  			team.sortList();

  			team.setSortBy('Team__r.Name');
  			team.sortList();  			

  			team.setSortBy('TeamProfile__r.Name');
  			team.sortList(); 
	
  		}catch(Exception e){
  			throw e;
  		}
   	}
}