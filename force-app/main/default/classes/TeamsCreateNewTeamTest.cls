@IsTest private class TeamsCreateNewTeamTest {
	
	/**
	*@testMethod
	*@void
	*/
	public static testMethod void testTeam() {
		try{
			TeamsCreateNewTeamController team = new TeamsCreateNewTeamController();
	    	List<SelectOption> optionType = team.getTypes();
			List<SelectOption>  optionProfile = team.getProfiles();
			Team__c t = [select Id from Team__c limit 1];
			team.setParam(t.Id);
			team.setTeam(t.Id);
			t = team.getTeam();
			team.getTeamImage();
			String picture = team.getTeamPicture();
		}catch(Exception e){
			throw e;
		}
   	}
}