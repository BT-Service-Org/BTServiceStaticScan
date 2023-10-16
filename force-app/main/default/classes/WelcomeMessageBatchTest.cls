@IsTest
public with sharing class WelcomeMessageBatchTest {

    @TestSetup
    static void createData(){
       MethodologyTestHelper.setupBaseDataForSlackTriggerBatch();
       MethodologyTestHelper.updateProjectSetupStatus(Label.Project_Status_Complete_Smartsheet_Sent);
    }

    @IsTest
    static void testBatch() {        

        MTH_SlackApiHandlerInterface mockHandler = MethodologyTestHelper.createMockSlackApiHandler();
        MTH_SlackUserIdHandler.slackApiHandler =  mockHandler;
        MTH_SlackMessageSender.slackApiHandler = mockHandler;

        Test.startTest();
        // Trigger the batch job to run immediately
        Database.executeBatch(new KickoffMessagesBatch());
        Test.stopTest();

        // Check that the project status has been updated
        PSA_Project__c updatedProject = [SELECT Project_Setup_Status__c FROM PSA_Project__c WHERE Name = :MethodologyTestHelper.TEST_PROJECT_NAME];
        System.assertEquals(true,((MethodologyTestHelper.Mock_MTH_SlackApiHandler)mockHandler).isPostMessageCalled,'Slack api post message not called.');
    }
}