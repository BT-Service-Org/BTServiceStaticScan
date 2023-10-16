@IsTest private class PeopleNewEditProfileTest {
    public static testMethod void testPeople() {
        try{
            ApexPages.StandardController controller;
            PeopleNewEditProfileController people = new PeopleNewEditProfileController(controller);
            
            people.setParam(UserInfo.getUserId());
            PeopleProfile__c peopleProfile = people.getMySidebarProfile();
            people.getStatus();
            people.getShowStatus();
            people.getMyPicture();
            people.getCurrentTime();
            people.findPeople();
            people.getPeopleSearchObj();
            people.getPProfile();
            people.getError();
            people.init();
            people.getPeopleProfile();          
            people.savePeopleProfile();
            people.cancelProfile();
            people.getNewUser();
            people.forwardTo('/apex/teamsOverview');
            
            PeopleNewEditProfileController.PeopleSearch peopleSrch = new PeopleNewEditProfileController.PeopleSearch();
            peopleSrch.setKeyword('word');
            peopleSrch.getKeyword();
            
            PeopleNewEditProfileController.Status status= new PeopleNewEditProfileController.Status();
            DateTime now = System.now();
            status.setModified(now);
            status.setMessage('Some Message');
            status.getMessage();
            
        }catch(Exception e){
            throw e;
        }
    }
}