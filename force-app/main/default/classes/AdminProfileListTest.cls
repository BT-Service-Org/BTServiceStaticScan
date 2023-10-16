@IsTest private class AdminProfileListTest {
    public static testMethod void testAdmin() {
        try
        {
            AdminProfileListController admin = new AdminProfileListController();
            admin.setOldIdProfile('ssdsdsdds');
            String TestinfGetoldProfile = admin.getOldIdProfile();
            admin.getTeamProfiles();            
        
            TeamProfile__c profile = [select Id, Name, CreatedDate, CreatedById from TeamProfile__c limit 1];
            AdminProfileListController.TeamProfile teamProfiles =  new AdminProfileListController.TeamProfile(profile);
            TeamProfile__c tp = teamProfiles.getTeamProfile();
            List<AdminProfileListController.TeamProfile> tp2 = admin.getProfiles ();
            admin.setOldIdProfile(tp2[0].teamProfile.Id);
            User u = tp2[0].getCreator();
            admin.setNewIdProfile(tp2[0].teamProfile.Id);
            String str = tp2[0].getCreatedDate();
            String str2 = admin.getNewIdProfile();
            String str3 = admin.getOldIdProfile();
            admin.reAssignUsers();

            // newProfile.getCreatorName();         
            
            
        } catch (DmlException e) {
            System.assert(false,'Data base error')  ;
        }
    }
}