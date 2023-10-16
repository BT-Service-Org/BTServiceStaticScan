@isTest
public with sharing class MTH_TestKickOffMsgHandler {
    private static UserDataAccessorMock userDaMock;
    private static ContactDataAccessorMock contactDaMock;
    private static PSA_ProjectDataAccessorMock psaDaMock;
    private static MTH_SlackApiHandlerMock slackApiMock;
    private static User mockUser;
    private static Contact contact1;
    private static PSA_Project__c testPSAProject;
    private static Project_Assignment__c testAssignment;
    private static List<Project_Assignment__c> assignments;

    private static void setup() {
        userDaMock = new UserDataAccessorMock();
        contactDaMock = new ContactDataAccessorMock();
        psaDaMock = new PSA_ProjectDataAccessorMock();
        assignments = new List<Project_Assignment__c>();

        mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.getSObjectType()),
            Slack_User_Id__c = 'testid'
        );

        contact1 = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.getSObjectType()),
            FirstName = 'John',
            LastName = 'Doe',
            User_Record__c = mockUser.Id
        );

        Contact contact2 = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.getSObjectType()),
            User_Record__c = mockUser.Id,
            FirstName = 'Test',
            LastName = 'User'
        );

        contactDaMock.contacts.add(contact1);
        contactDaMock.contacts.add(contact2);
        userDaMock.usersWSlackData.add(mockUser);
        MTH_SlackMessageSender.userDA = userDaMock;
        MTH_KickOffMsgHandler.userDA = userDaMock;
        MTH_KickOffMsgHandler.contactDA = contactDaMock;

        slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        testPSAProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.getSObjectType()),
            Name = 'mock psa_project',
            End_Date__c = DateTime.now().date()
        );

        psaDaMock.projects.add(testPSAProject);
        MTH_KickOffMsgHandler.projectDA = psaDaMock;

        testAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.getSObjectType()),
            End_Date__c = DateTime.now().date(),
            PSA_Project__c = testPSAProject.Id,
            Resource__c = contact1.Id,
            Name = 'mock assignment'
        );

        Project_Assignment__c testAssignment2 = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.getSObjectType()),
            End_Date__c = DateTime.now().date(),
            PSA_Project__c = testPSAProject.Id,
            Resource__c = contact2.Id,
            Name = 'ACME mock'
        );

        assignments.add(testAssignment);
        assignments.add(testAssignment2);
    }

    @isTest
    static void enqueueKickOffMsgGivenAssignment_shouldSendMessageToContacts() {
        setup();
        List<Project_Assignment__c> temp = new List<Project_Assignment__c>();
        temp.add(testAssignment);
        Test.startTest();
        System.enqueueJob(new MTH_KickOffMsgHandler(temp));
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send a message');
    }

    @isTest
    static void enqueueKickOffMsgGivenBulkAssignments_shouldSendMessageToContacts() {
        setup();
        Test.startTest();
        System.enqueueJob(new MTH_KickOffMsgHandler(assignments));
        Test.stopTest();

        System.assertEquals(2, slackApiMock.channelsSentMessage.size(), 'should send two messages');
    }
}