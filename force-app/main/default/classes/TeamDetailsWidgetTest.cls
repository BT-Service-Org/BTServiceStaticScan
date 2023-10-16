@IsTest private class TeamDetailsWidgetTest {
    public static testMethod void testTeam() {
        try{
            TeamDetailsWidgetController team = new TeamDetailsWidgetController();
            
            Team__c teamspace = team.getTeamspace();
            boolean  isTeamMember= team.getIsTeamMember();
            String member = team.getTeamMemberId();
            boolean  isTeamAdmin= team.getIsTeamAdmin();
            String adminStr = team.getTeamAdmins();
            Integer cnt = team.getTeamCount();
            String pic = team.getTeamspaceImage();
            String userName = team.getCurrentUser();
            team.genPermissions();
            UserPermissions up = team.getUserPermissions();
            
        }catch(Exception e){
            throw e;
        }
    }
}