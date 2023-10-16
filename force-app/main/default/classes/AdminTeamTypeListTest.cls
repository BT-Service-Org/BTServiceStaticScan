@IsTest private class AdminTeamTypeListTest {
    public static testMethod void testAdmin() {
        try{
	        AdminTeamTypeListController admin = new AdminTeamTypeListController();
	        admin.getTeamTypes();
	        TeamType__c teamType = [select Id, Name, CreatedDate, CreatedById from TeamType__c limit 1];
	        AdminTeamTypeListController.TeamTypes teamTypes =  new AdminTeamTypeListController.TeamTypes(teamType);
	        List<AdminTeamTypeListController.TeamTypes> profiles = admin.getTypes();
	        teamTypes.getCreatedDate();
	        teamTypes.getTeams();
	        teamTypes.getHasTeams();
	        teamTypes.getTeamType();
        }catch(Exception e){
        	throw e;
        }
    }
        
}