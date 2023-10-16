@IsTest
public class ProjectSetupBatchTest {

    @TestSetup
    static void createData(){
       MethodologyTestHelper.setupBaseDataForSlackTriggerBatch();
    }

    @IsTest
    static void testBatch() {        

        MTH_SlackApiHandlerInterface mockHandler = MethodologyTestHelper.createMockSlackApiHandler();
        MTH_SlackUserIdHandler.slackApiHandler =  mockHandler;
        MTH_SlackMessageSender.slackApiHandler = mockHandler;

        Test.startTest();
        // Trigger the batch job to run immediately
        Database.executeBatch(new ProjectSetupBatch());
        Test.stopTest();

        // Check that the project status has been updated
        PSA_Project__c updatedProject = [SELECT Project_Setup_Status__c FROM PSA_Project__c WHERE Name = :MethodologyTestHelper.TEST_PROJECT_NAME];
        System.assertEquals(Label.Project_Status_Welcome_Sent, updatedProject.Project_Setup_Status__c,'Project_Setup_Status__c is not set correctly');
    }
}