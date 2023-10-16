@isTest
public with sharing class MTH_TestUserSelectSubmit {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void userSelectModal_givenUserSelectedAndSubmitted_shouldUpdateMethods() {
        MTH_TestSetup.insertCustomSettings();

        UserDataAccessorMock userDaMock = buildUserDaMock();

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id,
            FirstName = 'Test',
            LastName = 'Test'
        );
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);

        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        Methods__c methods = new Methods__c( Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType), Completion_Status__c = 'Complete', OwnerId = userDaMock.usersWSlackData[0].Id, Assigned_Resource__c = userDaMock.usersWSlackData[0].Id);
        methodsDaMock.methods.add(methods);

        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(
            (PSA_Project__c) new MockSObjectBuilder(PSA_Project__c.SObjectType)
                .setId()
                .setChild(
                    'Method_for_Projects__r',
                    methodsDaMock.methods[0]
                )
                .build()
        );
        ProjectAssignmentDataAccessorMock assignDaMock = new ProjectAssignmentDataAccessorMock();
        assignDaMock.projectAssignments.add(
            new Project_Assignment__c(
                Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
                PSA_Project__c = projectDaMock.projects[0].Id,
                Start_Date__c = Date.newInstance(2022, 1, 1),
                End_Date__c = Date.today(),
                Resource__r = contactDaMock.contacts[0],
                Resource__c = contactDaMock.contacts[0].Id
            )
        );

        MTH_UserSelectModalHandler.projectAssignmentDA = assignDaMock;
        MTH_UserSelectModalHandler.methodsDA = methodsDaMock;
        MTH_UserSelectSubmit.methodsDa = methodsDaMock;
        MTH_ManageProjectViewOpen.projectDA = projectDaMock;
        MTH_ManageProjectViewOpen.methodsDA = methodsDaMock;
        MTH_ManageProjectViewOpen.userDA = userDaMock;

        
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

        Slack.TestHarness.Overflow methodOverflow = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );
        
        methodOverflow.clickOption(0);
        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();
        Slack.TestHarness.Input userSelectInput = (Slack.TestHarness.Input) newTopModal.getComponent(0, Slack.TestHarness.Input.class);
        Slack.TestHarness.SelectInput userSelect = (Slack.TestHarness.SelectInput) userSelectInput.getComponentByName('assign-user-select-name', Slack.TestHarness.SelectInput.class);
        List<Slack.TestHarness.Option> userOptions = userSelect.getOptions();
        userSelect.setValue(userOptions[0].getIdentifier());

        Test.startTest();
        newTopModal.submit();
        Test.stopTest();

        System.assertEquals(
            userDaMock.usersWSlackData[0].Id,
            methodsDaMock.methods[0].Assigned_Resource__c,
            'should update method assigned resource'
        );
    }

    private static UserDataAccessorMock buildUserDaMock(){
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
}