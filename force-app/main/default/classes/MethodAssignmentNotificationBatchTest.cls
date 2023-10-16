@IsTest
public with sharing class MethodAssignmentNotificationBatchTest {
    @TestSetup
    static void createData(){
       MethodologyTestHelper.setupBaseDataForSlackTriggerBatch();
       MethodologyTestHelper.updateProjectSetupStatus(Label.Project_Status_Message_Sent_With_Product_Details);
    }

    @IsTest
    static void testBatch() {        

        MTH_SlackApiHandlerInterface mockHandler = MethodologyTestHelper.createMockSlackApiHandler();
        MTH_SlackUserIdHandler.slackApiHandler =  mockHandler;
        MTH_SlackMessageSender.slackApiHandler = mockHandler;

        Test.startTest();
        // Trigger the batch job to run immediately
        Database.executeBatch(new MethodAssignmentNotificationBatch());
        Test.stopTest();

        // Check that the project status has been updated
        PSA_Project__c updatedProject = [SELECT Project_Setup_Status__c FROM PSA_Project__c WHERE Name = :MethodologyTestHelper.TEST_PROJECT_NAME];
        System.assertEquals(Label.Project_Status_Message_Notification_Sent_To_Resources, updatedProject.Project_Setup_Status__c,'Project_Setup_Status__c is not set correctly');
    }
}