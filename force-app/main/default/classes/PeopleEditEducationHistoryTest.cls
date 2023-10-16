@IsTest private class PeopleEditEducationHistoryTest {
    public static testMethod void testPeople() {
        try{
            PeopleEditEducationHistoryController people = new PeopleEditEducationHistoryController();

            EducationHistory__c edh = [select Id from EducationHistory__c limit 1];
            people.setParam(edh.Id);
            people.getEducationHistory(edh.Id);
            PeopleEditEducationHistoryController.PeopleSearch reference = new PeopleEditEducationHistoryController.PeopleSearch();
            
            PeopleProfile__c peopleProfile = people.getMySidebarProfile();
            
            PeopleEditEducationHistoryController.Status status= new PeopleEditEducationHistoryController.Status();
            DateTime now = System.now();
            status.setModified(now);
            status.setMessage ('Some Message');
            String s8 = status.getMessage();
            
            boolean exito= people.getDbOperation();
            String currentDate = people.getCurrentTime();
            String picture = people.getMyPicture();
            
            people.setEducationItem(new EducationHistory__c());
            PageReference page = people.save();
            
            people.setEducationItem(new EducationHistory__c());         
            PageReference page3 = people.saveAndAddAnother();
            PageReference page2 = people.remove();

            people.setIsNewRecord(false);
            
            people.setEducationItem(new EducationHistory__c());
            PageReference page7 = people.save();
            
            people.setEducationItem(new EducationHistory__c());         
            PageReference page8 = people.saveAndAddAnother();           
            
            PageReference page4 = people.cancel();
            PageReference page5 = people.forwardTo('/apex/teamsOverview');
            PageReference page6 = people.findPeople();
            
            PeopleEditEducationHistoryController.EducationItemObj education= new PeopleEditEducationHistoryController.EducationItemObj();
            
            education.setSchoolLocationState('School State');
            String s1 = education.getSchoolLocationState();
            
            education.setSchoolLocationCity('Some City');
            String s2 = education.getSchoolLocationCity();
            
            education.setSchool('School Name');
            String s3 = education.getSchool();
            
            education.setFieldsOfStudy('Some fields');
            String s4 = education.getFieldsOfStudy();
            
            education.setDegree('Degree');
            String s5 = education.getDegree();
            
            education.setAdditionalNotes('Some notes add');
            String s6 = education.getAdditionalNotes();
            
            education.setActivities('Some Activities');
            String s7 = education.getActivities();
            
            education.setAttendedTo(12.5);
            education.setAttendedFrom(20.3);
            Double d = education.getAttendedTo();
            
            List<SelectOption> so = people.getStates();
        }catch(Exception e){
            throw e;
        }
    }
}