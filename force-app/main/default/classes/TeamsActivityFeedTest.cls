@IsTest private class TeamsActivityFeedTest {
    public static testMethod void testTeam() {
        TeamsActivityFeedController  team = new TeamsActivityFeedController();

        team.setFilterStatus(true);
        Boolean filter = team.getFilterStatus();
        team.getMiniFeeds();

        team.setFilterFollow(true);
        Boolean filterFolow = team.getFilterFollow();
        team.getMiniFeeds();

        team.setFilterEducation(true);
        Boolean filterEducation = team.getFilterEducation();
        team.getMiniFeeds();

        team.setFilterCompetencies(true);
        Boolean filterComp = team.getFilterCompetencies();
        team.getMiniFeeds();
        
        team.setFilterMember(true);
        Boolean filterMem = team.getFilterMember();
        team.getMiniFeeds();
        
        team.setFilterDiscussion(true);
        Boolean filterDiscu = team.getFilterDiscussion();
        team.getMiniFeeds();
        
        team.setFilterAnnoncements(true);
        Boolean filterAnnon = team.getFilterAnnoncements();
        team.getMiniFeeds();
        
        team.setFilterProject(true);
        Boolean filterProj = team.getFilterProject();
        team.getMiniFeeds();
        
        List<TeamsActivityFeedController.miniFeed> feedsList = team.getFeedsList();                     
        TeamsActivityFeedController.miniFeed  feed= new TeamsActivityFeedController.miniFeed();
    }
}