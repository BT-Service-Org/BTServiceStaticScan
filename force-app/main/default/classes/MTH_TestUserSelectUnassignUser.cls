@isTest
public with sharing class MTH_TestUserSelectUnassignUser {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();
    private static PSA_ProjectDataAccessorMock projectDaMock;
    private static ProjectAssignmentDataAccessorMock assignDaMock;
    private static UserDataAccessorMock userDaMock;
    private static MethodsDataAccessorMock methodsDaMock;

    static void setupCommon() {
        userDaMock = buildUserDaMock();
        MTH_SlackUserIdHandler.userDA = userDaMock;
        MTH_SlackMessageSender.userDA = userDaMock;
        MTH_MethodsAssignMsgSender.userDA = userDaMock;

        User projectManagerUser = userDaMock.usersWSlackData[0];

        Contact mockContactPM = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = projectManagerUser.Id,
            FirstName = 'Test',
            LastName = 'Test'
        );

        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContactPM);
        assignDaMock = new ProjectAssignmentDataAccessorMock();

        MTH_UserSelectUnassignUser.projectAssignmentDA = assignDaMock;

        MTH_TestSetup.insertCustomSettings();

        methodsDaMock = new MethodsDataAccessorMock();
        Methods__c methods = new Methods__c(
            Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType),
            Completion_Status__c = 'Complete',
            CreatedById = MockSObjectBuilder.getMockId(User.SObjectType)
        );
        methodsDaMock.methods.add(methods);

        projectDaMock = new PSA_ProjectDataAccessorMock();
        PSA_Project__c psaProject = (PSA_Project__c) new MockSObjectBuilder(
                PSA_Project__c.SObjectType
            )
            .setField('Project_Manager__c',mockContactPM.Id)
            .setId()
            .setChild('Method_for_Projects__r', methodsDaMock.methods[0])
            .build();
        psaProject.Project_Manager__r = mockContactPM;
        
        projectDaMock.projects.add(psaProject);

        MTH_SlackAppMessengerMock messengerMock = new MTH_SlackAppMessengerMock();
        MTH_UserSelectUnassignUser.messenger = messengerMock;
        MTH_UserSelectUnassignUser.methodsDA = methodsDaMock;
        MTH_UserSelectUnassignUser.psaProjectDA = projectDaMock;

        
        MTH_UserSelectUnassignUser.messenger = new MTH_SlackAppMessenger();
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_SlackMessageSender.slackApiHandler = slackApiMock;
    }
    @isTest
    static void unassignUserButton_givenButtonIsClicked_shouldReassignMethodToPM() {
        setupCommon();
        try {
            userSession.executeSlashCommand('/methodologies', 'openTestModal', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'openTestModal', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Actions actionBlock = (Slack.TestHarness.Actions) modal.getComponent(
            0,
            Slack.TestHarness.Actions.class
        );

        Slack.TestHarness.Button unassignMethodBtn = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'unassign-method',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        unassignMethodBtn.click();
        Test.stopTest();

        System.assertEquals(
            userDaMock.usersWSlackData[0].Id,
            methodsDaMock.methods[0].Assigned_Resource__c,
            'should update method assigned resource'
        );

        System.assertEquals(
            userDaMock.usersWSlackData[0].Id,
            methodsDaMock.methods[0].OwnerId,
            'should update owner'
        );
    }

    private static UserDataAccessorMock buildUserDaMock() {
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        User mockUserPM = new User(
            Id = MockSObjectBuilder.getMockId(User.SObjectType),
            FirstName = 'project',
            LastName = 'manager',
            FederationIdentifier = 'pm@test.com',
            Email = 'pm@test.com',
            Slack_User_Id__c = 'testSlackIdPM'
        );

        userDaMock.usersWSlackData.add(mockUserPM);
        return userDaMock;
    }
}