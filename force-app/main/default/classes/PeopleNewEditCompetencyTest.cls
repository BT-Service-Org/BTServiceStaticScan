@IsTest private class PeopleNewEditCompetencyTest {
    public static testMethod void testPeople() {
        try{        
            ApexPages.StandardController controller ;
            PeopleNewEditCompetencyController people= new PeopleNewEditCompetencyController(controller);
            
            people.setUserId(UserInfo.getUserId());
            people.init();
            User u = people.getNewUser();
            PeopleProfile__c peopleProfile = people.getMySidebarProfile();
        
            PeopleNewEditCompetencyController.Status status = new PeopleNewEditCompetencyController.Status();
            DateTime now = System.now();
            status.setModified(now);
            String modif = status.getModified();
            status = people.getStatus();            
            
            String s = people.getCurrentTime();
            String pic = people.getMyPicture();
            Boolean showStat = people.getShowStatus();
            Boolean isNew = people.getIsNewRecord();
            
            PeopleNewEditCompetencyController.PeopleSearch ps = people.getPeopleSearchObj();            
            ps.setKeyword('word');
            String keyWord = ps.getKeyword();
                        
            people.getCompetency();
            Competency__c c = people.getNewCompetency();
            String s1 = people.getNameCompetency();
            String s2 = people.getReturnRating();
            String s3 = people.getError();
            UserCompetencies__c userCompetency = people.getNewUserCompetency();
            
            people.setNameCompetency('Competency Name');
            PageReference page = people.saveCompetency();               

            Competency__c comp = [select id, Name from Competency__c limit 1];
            people.setNewCompetency(comp);
            UserCompetencies__c userComp = [select Id, Name, User__c from UserCompetencies__c where User__c =: UserInfo.getUserId() limit 1];
            people.setNewUserCompetency(userComp);
            people.setNameCompetency('');
            PageReference page8 = people.saveCompetency();

            Competency__c comp2 = new Competency__c();
            comp2.Name = 'Competency Name 2'; 
            people.setNewCompetency(comp2);
            PageReference page7 = people.saveCompetency();
            
            PageReference page6 = people.saveAndNewCompetency();
            
            people.setUserCompId(userComp.Id);
            PageReference page2 = people.deleteCompetency();
            
            PageReference page3 = people.cancel();
            PageReference page4 = people.forwardTo('/apex/teamsOverview');
            PageReference page5 = people.cancelCompetency();
            PageReference page9 = people.findPeople();
            

        }catch(Exception e){
            throw e;
        }
    }
}