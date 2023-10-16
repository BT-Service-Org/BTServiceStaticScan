@IsTest private class AdminMainSetupTest {
	
	/**
	* Test Admin Main Setup
	*/
	public static testMethod void testAdmin() {
		
		AdminMainSetupController admin = new AdminMainSetupController();
		
		try{	
			admin.setNewIdProfile('aaaa');
			TeamProfile__c profile = [select Id, Name, CreatedDate, CreatedById from TeamProfile__c limit 1];
			AdminMainSetupController.TeamProfile teamProfiles=  new AdminMainSetupController.TeamProfile(profile);		
			admin.getTeamTypes();
			TeamType__c teamType = [select Id, Name, CreatedDate, CreatedById from TeamType__c limit 1];
			AdminMainSetupController.TeamTypes teamTypes=  new AdminMainSetupController.TeamTypes(teamType);
			admin.getTeamProfiles();
			List<AdminMainSetupController.TeamProfile> profiles = admin.getProfiles(); 
			admin.setOldIdProfile(profiles[0].teamProfile.Id);
			admin.reAssignUsers();			
			admin.getAll();
			String oldid = admin.getOldIdProfile();
			List<AdminMainSetupController.TeamTypes> types = admin.getTypes();
			Boolean b = teamTypes.getHasTeams();
			Integer i = teamTypes.getTeams();
			
			TeamProfile__c teamProfileItem = [select t.Id, t.CreatedById, t.CreatedDate, t.Name from TeamProfile__c t order by t.CreatedDate desc LIMIT 1];
						
			AdminMainSetupController.TeamProfile newProfile = new AdminMainSetupController.TeamProfile(teamProfileItem);
			TeamProfile__c testTeamProfile = newProfile.getTeamProfile();
			User testuser = newProfile.getCreator();
			String dateTest = newProfile.getCreatedDate();
			newProfile.getCreatorName();			
			admin.getAll();
			
		} catch (DmlException e) {
			System.assert(false,'Data base error')	;
		}
		
	}
}