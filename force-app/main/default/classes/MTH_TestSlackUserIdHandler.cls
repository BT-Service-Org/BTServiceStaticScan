@isTest
public with sharing class MTH_TestSlackUserIdHandler {
    @isTest
    private static void getSlackUserIdFromSFUser_givenUserSlackIdPopulated_shouldNotCallApi() {
        MTH_SlackApiHandlerMock slackApiHandlerMock = new MTH_SlackApiHandlerMock();
        MTH_SlackUserIdHandler.slackApiHandler = slackApiHandlerMock;
        String testSlackId = 'testid';
        User u = new User(Slack_User_Id__c = testSlackId);

        Test.startTest();
        String returnedId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
        Test.stopTest();

        System.assertEquals(
            0,
            slackApiHandlerMock.getUserByEmailCalls.size(),
            'should not have called api'
        );
        System.assertEquals(
            testSlackId,
            u.Slack_User_Id__c,
            'should have slack user id set correctly on user passed in'
        );
        System.assertEquals(testSlackId, returnedId, 'should return correct id');
    }

    @isTest
    private static void getSlackUserIdFromSFUser_givenUserSlackIdNotPopulated_shouldCallApi() {
        MTH_SlackApiHandlerMock slackApiHandlerMock = new MTH_SlackApiHandlerMock();
        MTH_SlackUserIdHandler.slackApiHandler = slackApiHandlerMock;
        User u = new User(FederationIdentifier = 'test@example.com');

        Test.startTest();
        String returnedId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
        Test.stopTest();

        System.assertEquals(
            1,
            slackApiHandlerMock.getUserByEmailCalls.size(),
            'should call api exactly once'
        );
        System.assertEquals('1', returnedId, 'should return id');
        System.assertEquals('1', u.Slack_User_Id__c, 'should set id on user object');
    }
}