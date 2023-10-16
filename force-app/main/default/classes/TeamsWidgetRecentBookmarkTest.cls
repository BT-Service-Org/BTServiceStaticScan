@IsTest private class TeamsWidgetRecentBookmarkTest {
    public static testMethod void testTeam() {
        try{
            //
            TeamsWidgetRecentBookmarkController team = new TeamsWidgetRecentBookmarkController();
            Team__c t = [select Id from Team__c limit 1];
            team.setTeamspaceId(t.Id);
            Id teamId = team.getTeamspaceId();
            List<Bookmark__c> bookmarks = team.getRecentBookmarks();
            team.setTeamspaceId(null); 
            bookmarks = team.getRecentBookmarks();
        }catch(Exception e){
            throw e;
        }
    }   
}