@IsTest private class TeamAdminQuickLinksTest {
    public static testMethod void testTeam() {
    TeamAdminQuickLinksController team = new TeamAdminQuickLinksController();
    boolean permissionAuthorApex = team.getPermissionAuthorApex();
    System.assert(permissionAuthorApex==true,'Tiene permiso de Author Apex');
    boolean isTeamAdmin = team.getIsTeamAdmin();
    System.assert(isTeamAdmin==true,'Tiene permiso de administrador'); 
        
    }   
}