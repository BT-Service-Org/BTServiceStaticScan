@IsTest private class TeamsDetailTest {
    
    public static String USERID =  UserInfo.getUserId();
    
    public static testMethod void testTeam() {
        try{
            TeamsDetailController team = new TeamsDetailController();
            Team__c t = [select Id from Team__c where NewMemberProfile__c != '' limit 1];
            team.setTeamIdParam(t.Id);
            team.getTeamDetail();
            t = team.getTeamspace();
            team.joinTeam();
            team.leaveTeam();
            Boolean open = team.getTeamIsOpen();
            String param = team.getTeamIdParam();
            Boolean message = team.getShowJoinTeamMessage();
            team.assignShowJoinTeamMessage();
            UserPermissions up = team.getUserPermissionsWiki();
            String image = team.getTeamspaceImage();
        }catch(Exception e){
            throw e;
        }
    }
}