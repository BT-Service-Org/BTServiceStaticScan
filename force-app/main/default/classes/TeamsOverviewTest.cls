@IsTest private class TeamsOverviewTest {

	public static testMethod void testTeam() {
		try{
			TeamsOverviewController team = new TeamsOverviewController();
			List<PeopleProfile__c> profiles = team.getPeopleProfile();
			TeamsOverviewController.teams t = new TeamsOverviewController.teams();
			TeamsOverviewController.Letters l = new TeamsOverviewController.Letters(); 
			
			team.setFilter('newTeams');
			team.teamsForTabs();
			team.setLetterFilter();
			PageReference pr = team.profileExist();
			
			team.setTeams(new List<TeamMember__c>());
			team.setFilter('recommendedTeams');
			team.teamsForTabs();			
			
			team.setTeams(new List<TeamMember__c>());
			team.setFilter('allTeams');
			team.teamsForTabs();
			
			team.setTeams(new List<TeamMember__c>());
			team.setFilter('');			
			team.teamsForTabs();
			
		}catch(Exception e){
			throw e;
		}	
	
	}
	
}