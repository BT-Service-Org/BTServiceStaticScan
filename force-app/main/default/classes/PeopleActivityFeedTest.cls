@IsTest private class PeopleActivityFeedTest {
    public static testMethod void testPeople() {
        PeopleActivityFeedController people = new PeopleActivityFeedController();
        PeopleProfile__c peopleProfile = people.getMySidebarProfile();
        PeopleActivityFeedController.Status status= new PeopleActivityFeedController.Status();
        DateTime now = System.now();
        status.setModified(now);
        String modified = status.getModified();
        status.setMessage('Message');
        String message = status.getMessage();
        PeopleActivityFeedController.Profile profile = new PeopleActivityFeedController.Profile();  
        List<PeopleActivityFeedController.miniFeed> listMiniFeeds = people.getMiniFeeds();  
        PeopleActivityFeedController.miniFeed miniFeed = new PeopleActivityFeedController.miniFeed();
        String str = miniFeed.getTypeOfFeed();
        String str2 = miniFeed.getName();
        miniFeed.setName('Joe');
        miniFeed.setUser('Joe');
        String str3 = miniFeed.getUser();
        miniFeed.setMessage('Message');
        String str4 = miniFeed.getMessage();
        miniFeed.setFeedDate(System.now());
        Datetime d = miniFeed.getFeedDate();
        miniFeed.setFeedDateString('2008-01-01');
        String dStr = miniFeed.getFeedDateString();
        PeopleActivityFeedController.Profile p = people.getProfile();
        p.setId(p.getId());
        Id id = p.getId();
        p.setFirstName('Joe');
        String nStr = p.getFirstName();
        PeopleActivityFeedController.PeopleSearch ps = new PeopleActivityFeedController.PeopleSearch ();
        ps.setKeyword('Java');
        String keyStr = ps.getKeyword();
        PageReference pr = people.findPeople();
        String pic = people.getMyPicture();
        Boolean b = people.getShowStatus();
    }
}