@isTest
public with sharing class MTH_TestWelcomeMessageHandler {
    @isTest
    private static void sendWelcomeMessageToUser_givenProjectAssignments_shouldSendWelcomeMessageToUser() {
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.getSObjectType()),
            Slack_User_Id__c = 'testid'
        );
        userDaMock.usersWSlackData.add(mockUser);

        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.getSObjectType()),
            FirstName = 'John',
            LastName = 'Doe',
            User_Record__c = mockUser.Id
        );
        contactDaMock.contacts.add(mockContact);
            
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(
            (PSA_Project__c) new MockSObjectBuilder(PSA_Project__c.SObjectType)
                .setId()
                .setChild(
                    'Method_for_Projects__r',
                    new Methods__c(
                        Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType),
                        End_Date__c = Date.newInstance(2035, 12, 31)
                    )
                )
                .build()
        );

        ProjectAssignmentDataAccessorMock assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            PSA_Project__c = projectDaMock.projects[0].Id,
            Start_Date__c = Date.newInstance(2022, 1, 1),
            End_Date__c = Date.today(),
            Resource__c = mockContact.Id,
            Resource__r = mockContact,
            Project_Role__c = 'Project Manager'
        );
        assignmentDaMock.projectAssignments.add(mockAssignment);

        MTH_WelcomeMsgHandler.contactDA = contactDaMock;
        MTH_WelcomeMsgHandler.userDA = userDaMock;
        MTH_SlackMessageSender.userDA = userDaMock;
        MTH_SlackUserIdHandler.userDA = userDaMock;
        
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;
        MTH_SlackUserIdHandler.slackApiHandler = slackApiMock;

        Test.startTest();
        System.enqueueJob(new MTH_WelcomeMsgHandler(new List<Project_Assignment__c>{mockAssignment}));
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send 1 message');
    }
}