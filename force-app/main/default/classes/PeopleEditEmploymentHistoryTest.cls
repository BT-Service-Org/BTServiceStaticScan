@IsTest private class PeopleEditEmploymentHistoryTest {
    public static testMethod void testPeople() {
        try{
            PeopleEditEmploymentHistoryController people = new PeopleEditEmploymentHistoryController();
            
            PeopleEditEmploymentHistoryController.PeopleSearch search = new PeopleEditEmploymentHistoryController.PeopleSearch();
            search.getKeyword();
            search.setKeyword('word');
            
            PeopleProfile__c peopleProfile = people.getMySidebarProfile();
            
            PeopleEditEmploymentHistoryController.EmploymentItemObj employ = new PeopleEditEmploymentHistoryController.EmploymentItemObj();
            employ.setEmployerLocationCity('');
            employ.getEmployerLocationState();
            employ.setEmployerLocationState('');
            employ.getYearFrom();
            employ.setYearFrom(1);
            employ.getYearTo();
            employ.setYearTo(1);
            employ.getWorkedFromMonth();
            employ.setWorkedFromMonth('');
            employ.getWorkedToMonth();
            employ.setWorkedToMonth('');
            employ.getworkedTo();
            employ.getworkedFrom();
            employ.setDescription('');
            employ.getDescription();
            employ.setEmployer('');
            employ.getEmployer();
            employ.setTitle('');
            employ.getTitle();
            employ.setCurrentJob(true);
            employ.getCurrentJob();
                    
            people.getStatus();
            people.getMonthNumber('');
            people.getCurrentTime();
            people.getStates();
            people.getIsNewRecord();
            people.setEmploymentItem(new EmploymentHistory__c());
            people.getEm();
            people.getEmployer();
            for(Integer it = 1; it <= 12; it++){
                people.getMonthName(it);
            }
            people.getPeopleSearchObj();
            people.findPeople();
            people.getMyPicture();
            people.getShowStatus();
            people.getError();
            people.getMonths();
            
            PeopleEditEmploymentHistoryController.Status status = new PeopleEditEmploymentHistoryController.Status();
            DateTime now = System.now();
            EmploymentHistory__c eh = [select Id from EmploymentHistory__c where IsCurrentJob__c = true limit 1];
            
            people.setParam(eh.Id);
            status.setModified(now);
            people.getEmploymentHistory(eh.Id);
            boolean exito= people.getDbOperation();
            
            PageReference page= people.remove();
            
            people.setEmploymentItem(new EmploymentHistory__c());
            PageReference page2= people.saveAndAddAnother();
            
            people.setEmploymentItem(new EmploymentHistory__c());
            PageReference page3= people.save();
            PageReference page4 = people.forwardTo('/apex/teamsOverview');
            people.cancel();
            
        }catch(Exception e){
            throw e;
        }
    }
}