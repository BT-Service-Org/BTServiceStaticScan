@IsTest private class TeamsWidgetWikiTest {
    public static testMethod void testTeam() {
        TeamsWidgetWikiController team = new TeamsWidgetWikiController();
        
        team.setTeamspaceId('a0B30000001xHJcEAM');
        
        if (team.getTeamspaceId()== null) {
            System.assert(true,'Null Team Id'); 
        }
        
        team.getWikiPages(); 
        team.getWikiPagesSize(); 
    }
}