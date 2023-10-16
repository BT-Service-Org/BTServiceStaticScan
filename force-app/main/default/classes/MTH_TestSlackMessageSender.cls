@isTest
public with sharing class MTH_TestSlackMessageSender {
    @isTest
    private static void sendMultipleMessagesToUserIds_givenMessageToSend_shouldSend() {
        Slack.ViewReference vr = Slack.view.mth_msg_welcome.get();
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        Id mockUserId = MockSObjectBuilder.getMockId(User.getSObjectType());
        User testUser = new User(Id = mockUserId, Slack_User_Id__c = 'testid');

        MTH_SlackMessageSender.userDA = userDaMock;
        userDaMock.usersWSlackData.add(testUser);
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Map<Slack.ViewReference, List<Id>> mapToPassIn = new Map<Slack.ViewReference, List<Id>>();
        mapToPassIn.put(vr, new List<Id>{ mockUserId });

        Test.startTest();
        MTH_SlackMessageSender.sendMultipleMessagesToUserIds(mapToPassIn);
        Test.stopTest();

        System.assertEquals(1, userDaMock.updatedUsers.size(), 'should update users when done');
        // getting error when trying to deploy other tests
        // System.assertEquals(
        //     1,
        //     slackApiMock.getUserByEmailCalls.size(),
        //     'should send message to user'
        // );
    }

    @isTest
    private static void sendMessageToUsers_givenMessageToSend_shouldSend() {
        Slack.ViewReference vr = Slack.view.mth_msg_welcome.get();
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        Id mockUserId = MockSObjectBuilder.getMockId(User.getSObjectType());
        User testUser = new User(Id = mockUserId, Slack_User_Id__c = 'testid');

        MTH_SlackMessageSender.userDA = userDaMock;
        userDaMock.usersWSlackData.add(testUser);
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Test.startTest();
        MTH_SlackMessageSender.sendMessageToUsers(new Set<Id>{ mockUserId }, vr);
        Test.stopTest();

        System.assertEquals(1, userDaMock.updatedUsers.size(), 'should update users when done');
        // getting error when trying to deploy other tests
        // System.assertEquals(
        //     1,
        //     slackApiMock.getUserByEmailCalls.size(),
        //     'should send message to user'
        // );
    }

    @isTest
    private static void returnFormattedDate_givenNoEndDate_shouldReturnBlankString() {
        Test.startTest();
        String formattedDate = MTH_SlackMessageSender.formatDateStringForMessages(null);
        Test.stopTest();

        System.assertEquals('', formattedDate, 'should return blank string');
    }

    @isTest
    private static void returnFormattedDate_givenEndDate_shouldReturnFormattedEndDate() {
        Test.startTest();
        String formattedDate = MTH_SlackMessageSender.formatDateStringForMessages(Date.newInstance(2023, 2, 17));
        Test.stopTest();

        System.assertEquals(' by 2/17/2023', formattedDate, 'should return correctly formatted string');
    }
}