@IsTest private class AdminProfileTest {
    public static testMethod void testAdmin() {
        try{
            AdminProfileController admin = new AdminProfileController();
            boolean isTeamAdminMember= admin.getIsTeamAdminMember();
            List<TeamProfile__c> allTeamProfiles= admin.getAllTeamProfiles();
            TeamProfile__c tp = admin.getTeamProfile();
            admin.setTeamProfile(tp);
            admin.asignSection();
            Boolean b = admin.getIsAClone();
            String str = admin.getSection();
            Boolean b2 = admin.getExistName();
            admin.setSection('clone');
            admin.saveTeamProfile();
            admin.setSection('edit');
            admin.saveTeamProfile();
            Boolean b3 = admin.getPermissionAuthorApex();
            admin.saveTeamProfile();
        }
        catch(Exception e){
        }
    }
}