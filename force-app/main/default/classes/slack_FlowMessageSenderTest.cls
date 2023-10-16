@isTest
global with sharing class slack_FlowMessageSenderTest {

    @isTest
    static void testGoodPersonalNotification(){
        Id mockUserId = MockSObjectBuilder.getMockId(User.getSObjectType());
        User testUser = new User(Id = mockUserId, Slack_User_Id__c = 'testid');
        slack_FlowMessageSender.SlackMessage slackMessage = new slack_FlowMessageSender.SlackMessage();
        slackMessage.channel = mockUserId;
        slackMessage.messageText = 'This is a test message';

        List<slack_FlowMessageSender.SlackMessage> messages = new List<slack_FlowMessageSender.SlackMessage>();
        messages.add(slackMessage);

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        slack_FlowMessageSender.slackApi = slackApiMock;
        slack_FlowMessageSender.testUser = testUser;

        Test.startTest();
        List<String> result = slack_FlowMessageSender.sendMessage(messages);
        Test.stopTest();
        System.assertEquals(result[0], 'Messages sent successfully');

    }


    @isTest
    static void testGoodChannelNotification(){
        slack_FlowMessageSender.SlackMessage slackMessage = new slack_FlowMessageSender.SlackMessage();
        slackMessage.channel = 'C03TZ7N1LLQ';
        slackMessage.messageText = 'This is a test message';

        List<slack_FlowMessageSender.SlackMessage> messages = new List<slack_FlowMessageSender.SlackMessage>();
        messages.add(slackMessage);

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        slack_FlowMessageSender.slackApi = slackApiMock;

        Test.startTest();
        List<String> result = slack_FlowMessageSender.sendMessage(messages);
        Test.stopTest();

        System.assertEquals(result[0], 'Messages sent successfully');

        
    }


}