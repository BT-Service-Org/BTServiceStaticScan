@isTest
public with sharing class MTH_TestMethodsAssignMsgSender {
    @isTest
    private static void execute_givenMethodsAssigned_shouldNotifyNewOwners() {
        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.SObjectType),
            Slack_User_Id__c = 'mockSlackId'
        );
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        userDaMock.usersWSlackData.add(mockUser);
        MTH_MethodsAssignMsgSender.userDA = userDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
            
        Methods__c testMethods = new Methods__c();
        testMethods = (Methods__c)JSON.deserialize('{"Name":"mock method"}',Methods__c.class);
        testMethods.Id = MockSObjectBuilder.getMockId(Methods__c.getSObjectType());
        testMethods.End_Date__c = DateTime.now().date();
        testMethods.OwnerId = mockUser.Id;
        testMethods.Assigned_Resource__c = mockUser.Id;
        testMethods.Method__r = mockMethod;
            
        ArticleMethodDataAccessorMock articleMethodDAMock = new ArticleMethodDataAccessorMock();
        MTH_MethodsAssignMsgSender.articleMethodDA = articleMethodDAMock;
        Article_Method__c mockArticleMethod = new Article_Method__c(
            Id = MockSObjectBuilder.getMockId(Article_Method__c.getSObjectType()),
            Method__r = mockMethod
        );
        articleMethodDAMock.articleMethods.add(mockArticleMethod);

        Test.startTest();
        System.enqueueJob(new MTH_MethodsAssignMsgSender(new List<Methods__c>{ testMethods }));
        Test.stopTest();

        System.assertEquals(
            1,
            slackApiMock.channelsSentMessage.size(),
            'should call api to send message'
        );
    }
}