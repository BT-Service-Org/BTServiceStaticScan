@isTest
private class TC_resource_scheduler {

    static testMethod void myUnitTest() {

        // Instantiate a new controller with all parameters in the page
        resource_scheduler rs = new resource_scheduler();
        rs.getScheduleWeeks('test value'); 
    }
}