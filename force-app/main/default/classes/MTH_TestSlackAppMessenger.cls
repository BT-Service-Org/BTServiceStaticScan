@isTest
public with sharing class MTH_TestSlackAppMessenger {
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
    private static void sendMethodDueMessages_givenMethods_shouldSendMessages() {
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
        new MTH_SlackAppMessenger().sendMethodDueMessages(new List<Methods__c>{ mockMethods });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send message');
    }

    @isTest
    private static void sendMethodAssignedMessages_givenMethods_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_MethodsAssignMsgSender.userDA = userDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Methods__c mockMethods = new Methods__c();
        mockMethods = (Methods__c)JSON.deserialize('{"Name":"test method"}',Methods__c.class);
        mockMethods.Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        mockMethods.End_Date__c = DateTime.now().date(); 
        mockMethods.OwnerId = userDaMock.usersWSlackData[0].Id;
        mockMethods.Assigned_Resource__c = userDaMock.usersWSlackData[0].Id;

        Test.startTest();
        new MTH_SlackAppMessenger().sendMethodAssignedMessages(new List<Methods__c>{ mockMethods });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send message');
    }

    @isTest
    private static void sendKickOffMessages_givenMethods_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_KickOffMsgHandler.userDA = userDaMock;

        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        );
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(mockProject);
        MTH_KickOffMsgHandler.projectDA = projectDaMock;

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id
        );
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);
        MTH_KickOffMsgHandler.contactDA = contactDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            PSA_Project__c = mockProject.Id,
            Resource__c = mockContact.Id
        );

        Test.startTest();
        new MTH_SlackAppMessenger()
            .sendKickOffMessages(new List<Project_Assignment__c>{ mockAssignment });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send message');
    }

    @isTest
    private static void sendWelcomeMessages_givenProjectId_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_WelcomeMsgHandler.userDA = userDaMock;

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id
        );
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);
        MTH_WelcomeMsgHandler.contactDA = contactDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        );
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(mockProject);
        MTH_WelcomeMsgHandler.psaProjectDA = projectDaMock;

        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            Resource__c = mockContact.Id,
            Project_Role__c = 'Business Analyst'
        );

        Project_Assignment__c mockAssignmentManager = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            Resource__c = mockContact.Id,
            Project_Role__c = 'Project Manager'
        );

        Test.startTest();
        new MTH_SlackAppMessenger().sendWelcomeMessages(new List<Project_Assignment__c>{ mockAssignment, mockAssignmentManager });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send one message');
    }

    @isTest
    private static void sendSetUpMessages_givenProjectId_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_SetupMsgHandler.userDA = userDaMock;

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id
        );
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);
        MTH_SetupMsgHandler.contactDA = contactDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType),
            Name = 'Test'
        );

        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            Resource__c = mockContact.Id,
            Project_Role__c = 'Business Analyst',
            PSA_Project__r = mockProject
        );

        Project_Assignment__c mockAssignmentManager = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            Resource__c = mockContact.Id,
            Project_Role__c = 'Project Manager',
            PSA_Project__r = mockProject
        );

        Test.startTest();
        new MTH_SlackAppMessenger().sendSetupMessages(new List<Project_Assignment__c>{ mockAssignment, mockAssignmentManager });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send one message');
    }

    @isTest
    private static void sendGenericMessages_shouldSendMessages() {
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_GenericMsgHandler.userDA = userDaMock;

        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        MTH_MessagePayload payload = new MTH_MessagePayload();


        Test.startTest();
        new MTH_SlackAppMessenger().sendGenericMessages(new List<MTH_MessagePayload>{payload});
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send one message');
    }

    @isTest
    private static void sendSmartsheetMessages_givenMethods_shouldSendMessages(){
        UserDataAccessorMock userDaMock = buildUserDaMock();
        MTH_SmartSheetLinkMsg.userDA = userDaMock;
		
        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id
        );
        
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);
        MTH_SmartSheetLinkMsg.contactDA = contactDaMock;
        
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;

        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType),
            Name = 'Acme',
            Smartsheet_Link__c = 'test.com'
        );
		
        Project_Assignment__c mockAssignmentManager = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
            Name = 'test assignment',
            Resource__c = mockContact.Id,
            Project_Role__c = 'Project Manager',
            PSA_Project__r = mockProject
        );

        Test.startTest();
        new MTH_SlackAppMessenger().sendSmartsheetMessages(new List<Project_Assignment__c>{mockAssignmentManager });
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should send message');
    }

}