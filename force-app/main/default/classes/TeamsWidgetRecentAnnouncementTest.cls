@IsTest private class TeamsWidgetRecentAnnouncementTest {
    public static testMethod void testTeam() {
        try{
            TeamsWidgetRecentAnnouncementController team = new TeamsWidgetRecentAnnouncementController();
            Team__c t = [select Id from Team__c limit 1];
            team.setTeamspaceId(t.Id);
            Id teamId = team.getTeamspaceId();
            List<BlogEntry__c> blogs = team.getRecentAnnouncements();
            team.setTeamspaceId(null);
            blogs = team.getRecentAnnouncements();          
        }catch(Exception e){
            throw e;
        }
    }
}