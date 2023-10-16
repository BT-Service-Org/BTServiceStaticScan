@isTest
public with sharing class MTH_TestSlackProjectKTDataHandler {
    private static UserDataAccessorMock userDaMock;
    private static ProjectAssignmentDataAccessorMock assignmentDaMock;
    private static MTH_SlackApiHandlerMock slackApiMock;
    private static User mockUser;
    private static PSA_Project__c testPSAProject;
    private static List<Project_Assignment__c> assignments;
    private static String targetChannelId;
    private static String spwLink;
    private static String accountChannelId;
    private static String teamId;
    private static String userId;

    private static void setup() {

        targetChannelId = 'targetChannelId';
        spwLink = 'https://example.com';
        accountChannelId = 'accountChannelId';
        teamId = 'teamid';
        userId = 'userid';

        testPSAProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.getSObjectType()),
            Name = 'mock psa_project',
            End_Date__c = Date.today()
        );

        mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.getSObjectType()),
            Slack_User_Id__c = 'testid'
        );

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.getSObjectType()),
            FirstName = 'John',
            LastName = 'Doe',
            User_Record__c = mockUser.Id
        );

        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            PSA_Project__c = testPSAProject.Id,
            Start_Date__c = Date.newInstance(2022, 1, 1),
            End_Date__c = Date.today(),
            Resource__c = mockContact.Id,
            Resource__r = mockContact,
            Project_Role__c = 'Project Manager'
        );

        userDaMock = new UserDataAccessorMock();
        userDaMock.usersWSlackData.add(mockUser);

        assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        assignmentDaMock.projectAssignments.add(mockAssignment);

        slackApiMock = new MTH_SlackApiHandlerMock();

        MTH_SlackProjectKTDataHandler.assignmentDa = assignmentDaMock;
        MTH_SlackProjectKTDataHandler.userDA = userDaMock;
        MTH_SlackProjectKTDataHandler.slackApiHandler = slackApiMock;
    }

    @isTest
    static void enqueueSlackProjectKTDataHandler_shouldInviteUsers() {
        setup();
        
        Test.startTest();
        System.enqueueJob(new MTH_SlackProjectKTDataHandler(testPSAProject, targetChannelId, spwLink, accountChannelId, teamId, userId));
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelInviteCalls.size(), 'should invite users');
    }

    @isTest
    static void enqueueSlackProjectKTDataHandler_shouldSendMessage() {
        setup();
        Test.startTest();
        System.enqueueJob(new MTH_SlackProjectKTDataHandler(testPSAProject, targetChannelId, spwLink, accountChannelId, teamId, userId));
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsPinnedSentMessage.size(), 'should send a pinned message');
        System.assertEquals(0, slackApiMock.channelsSentMessage.size(), 'should not apply fallback');

    }

    @isTest
    static void enqueueSlackProjectKTDataHandler_shouldFallbackOnSendingIssues() {
        setup();
        // For the negetive case
        slackApiMock.postPinnedMessageExpectedResult = null;
        

        Test.startTest();
        System.enqueueJob(new MTH_SlackProjectKTDataHandler(testPSAProject, targetChannelId, spwLink, accountChannelId, teamId, userId));
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsPinnedSentMessage.size(), 'should firstly try to send a pinned message');
        System.assertEquals('userid', slackApiMock.channelsSentMessage[0], 'fallback messages should be DMs');
        System.assertEquals('userid', slackApiMock.channelsSentMessage[1], 'fallback messages should be DMs');
    }
}