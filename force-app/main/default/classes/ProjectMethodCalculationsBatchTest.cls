@isTest
public with sharing class ProjectMethodCalculationsBatchTest {
    
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }
    @isTest
    static void testBatch(){
        Test.startTest();
        ProjectMethodCalculationsBatch b = new ProjectMethodCalculationsBatch();
        Database.executeBatch(b);
        Test.stopTest();

        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        Assert.areEqual( MethodologyConstants.PROJECT_STATUS_DONE, proj.Method_for_Engagement_status__c);
    }
}