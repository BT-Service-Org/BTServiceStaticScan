@isTest
public with sharing class MTH_TestMethodDueMsgSender {
    private static UserDataAccessorMock buildUserDaMock() {
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.SObjectType),
            FirstName = 'test',
            LastName = 'user',
            FederationIdentifier = 'test@test.com',
            Email = 'test@test.com',
            Slack_User_Id__c = 'testSlackId'
        );
        userDaMock.usersWSlackData.add(mockUser);
        return userDaMock;
    }

    @isTest
    private static void execute_givenMethods_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_MethodDueMsgSender.userDA = userDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Methods__c mockMethods = new Methods__c();
        mockMethods = (Methods__c)JSON.deserialize('{"Name":"test method"}',Methods__c.class);
        mockMethods.Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        mockMethods.End_Date__c = DateTime.now().date();
        mockMethods.OwnerId = userDaMock.usersWSlackData[0].Id;
        mockMethods.Assigned_Resource__c = userDaMock.usersWSlackData[0].Id;
        
        Test.startTest();
        System.enqueueJob(
            new MTH_MethodDueMsgSender(new List<Methods__c>{ mockMethods })
        );
        Test.stopTest();

        System.debug(mockMethods);

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send message');
    }
}