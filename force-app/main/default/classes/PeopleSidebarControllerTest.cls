@IsTest private class PeopleSidebarControllerTest {
    public static testMethod void testProjectTaskDetailController() {
        try{
            PeopleSidebarProfileController sidebar = new PeopleSidebarProfileController();
            
            List<PeopleProfile__c> profiles = sidebar.getPeopleProfile();
            String s1 = sidebar.getCurrentTime();
            String s2 = sidebar.getMyPicture();
            PeopleProfile__c profile = sidebar.getMySidebarProfile();
            sidebar.subscriptionCounts();
            Integer n1 = sidebar.getCountImSubscribedTo();
            Integer n2 = sidebar.getCountSubscribedToMe();
            Boolean b1 = sidebar.getShowSubscribedPeople();
            
            PeopleSidebarProfileController.Status status = new PeopleSidebarProfileController.Status();
            status = sidebar.getStatus();
            status.setModified(System.now());
            String s3 = status.getModified();
            
        }catch(Exception e){
            throw e;
        }
    }
}