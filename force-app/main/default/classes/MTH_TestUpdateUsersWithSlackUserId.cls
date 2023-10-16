@isTest
public with sharing class MTH_TestUpdateUsersWithSlackUserId {
    @isTest
    private static void queueableJob_givenUsersWNoSlackId_shouldUpdateUsers() {
        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.getSObjectType()),
            FederationIdentifier = 'test@salesforce.com',
            Slack_User_Id__c = null
        );

        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        MTH_UpdateUsersWithSlackUserId.userDa = userDaMock;
        MTH_SlackUserIdHandler.slackApiHandler = new MTH_SlackApiHandlerMock();
        userDaMock.usersWSlackData.add(mockUser);

        Test.startTest();
        System.enqueueJob(new MTH_UpdateUsersWithSlackUserId(new Set<Id>{ mockUser.Id }));
        Test.stopTest();

        System.assertEquals(1, userDaMock.updatedUsers.size(), 'should update user');
    }
}