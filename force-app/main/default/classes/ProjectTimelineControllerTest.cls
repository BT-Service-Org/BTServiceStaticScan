@IsTest private class ProjectTimelineControllerTest {

    /**
    * Test for run code coverage for current class
    *@void
    *@static
    */
    public static testMethod void testTimelineController (){
        ProjectTimelineController pc = new ProjectTimelineController();
        Team__c t = [select Id, Name from Team__c limit 1];
        pc.getTeamAndProject(t.Id);
        t = pc.getTeam();
        Project2__c p = pc.getProject();    
    }
}