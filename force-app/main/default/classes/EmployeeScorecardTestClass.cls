@isTest
private class EmployeeScorecardTestClass {

	static testMethod void myUnitTest() {
		//CREATE PROJECT FEEDBACK RECORDS
        List<Employee_Scorecard__c> esList = new List<Employee_Scorecard__c>();
        for (Integer x = 0; x < 10; x++){
    		Employee_Scorecard__c es = new Employee_Scorecard__c(
                            Employee_Name__c = '00530000000o7RR',
                            Name = 'Test Project Feedback',
                            OwnerId = '00530000000o7RR',
                            Scorecard_Date__c = date.newinstance(2009, 01, 19));
			esList.add(es);
        }
        insert esList;	
	}
}