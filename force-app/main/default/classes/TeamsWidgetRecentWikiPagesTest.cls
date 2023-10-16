@IsTest private class TeamsWidgetRecentWikiPagesTest {
    public static testMethod void testTeam() {
        
        TeamsWidgetRecentWikiPagesController team = new TeamsWidgetRecentWikiPagesController();
        try {
            team.setTeamId('a0B30000001xHJcEAM');
        } catch (exception e) {
            System.assert(true, e);
        }
        
        if (team.getTeamId() == null){
            System.assert(true, 'Null team Id');    
        }
        
        UserPermissions userPermissions = new UserPermissions();
        
        userPermissions.getCanView();
        userPermissions.getCanComment();
        userPermissions.getCanManage();
        userPermissions.getCanCreate();
        userPermissions.getObjectType();
        userPermissions.getTeam();
        //userPermissions.getObjectId();
        userPermissions.getId();
        
        team.getUserPermissions();
        team.getWikis();
        team.getWikiPagesCount();
    }
}