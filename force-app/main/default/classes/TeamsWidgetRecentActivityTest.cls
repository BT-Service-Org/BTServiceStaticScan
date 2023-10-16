@IsTest private class TeamsWidgetRecentActivityTest {
    public static testMethod void testTeam() {
        try{
	        TeamsWidgetRecentActivityController team= new TeamsWidgetRecentActivityController();
	        List<TeamsWidgetRecentActivityController.miniFeed> feeds = team.getMiniFeeds();   
	       
	        TeamsWidgetRecentActivityController.miniFeed feed = new TeamsWidgetRecentActivityController.miniFeed();
	        feed.getTypeOfFeed();
	        feed.setTypeOfFeed('String');
	        feed.getName();
	        feed.getUser();
	        feed.setUser('User name');
	        feed.getMessage();
	        feed.setMessage('String Message');
	        feed.getFeedDate();
	        feed.setFeedDate(System.now());
	        feed.setFeedDateString('String');
	        feed.getFeedDateString();
	        feed.getFeedDateClass();
	        feed.setFeedDateClass('String');

        }catch(Exception e){
    		throw e;
    	}
    }

}