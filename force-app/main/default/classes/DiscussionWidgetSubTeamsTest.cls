@IsTest private class DiscussionWidgetSubTeamsTest {

public static String teamId = System.currentPageReference().getParameters().get('id');
    public static testMethod void testDiscussion() {
        DiscussionWidgetSubTeamsController dis = new DiscussionWidgetSubTeamsController();
        DiscussionWidgetSubTeamsController.subTeams sub = new DiscussionWidgetSubTeamsController.subTeams();
        
        //String idTeam = [select id from Team__c limit 1].id;
        //I have to hardcode the team id because the team need to have at least one subteam.
        String idTeam = 'a0B30000001xHJcEAM';
        dis.setTeamId(idTeam);
        
        dis.getCountSubTeams();
        dis.getSubTeams();

        sub.getName();
        sub.getId();
        sub.getCount();
        
    }       
}