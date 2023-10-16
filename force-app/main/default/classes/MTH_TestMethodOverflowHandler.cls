@isTest
public with sharing class MTH_TestMethodOverflowHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();
    private static MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
    private static String methodId;

    @isTest
    private static void clickViewDetails_shouldOpenMethodDetailsModal() {
        MTH_TestSetup.insertCustomSettings();
        Test.startTest();
        mockSetup();
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

        Slack.TestHarness.Overflow overflowSelect = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );

        overflowSelect.clickOption(1);
        Test.stopTest();

        Slack.TestHarness.Modal detailsModal = userSession.getTopModal();
        String modalTitle = detailsModal.getTitle();

        System.assert(modalTitle.startsWith('Method #'), 'should open method details modal');
    }

    @isTest
    private static void clickCompleteMethod_shouldOpenCompleteMethodModal() {
        MTH_TestSetup.insertCustomSettings();
        Test.startTest();
        mockSetup();
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

        Slack.TestHarness.Overflow overflowSelect = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );
        overflowSelect.clickOption(2);
        Test.stopTest();

        Slack.TestHarness.Modal completeMethodModal = userSession.getTopModal();
        String modalTitle = completeMethodModal.getTitle();

        System.assertEquals('Complete Method', modalTitle, 'should open complete method modal');
    }

    @isTest
    private static void clickAssignMethod_shouldOpenAssignMethodModal() {
        MTH_TestSetup.insertCustomSettings();
        Test.startTest();
        mockSetup();
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

        Slack.TestHarness.Overflow overflowSelect = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );
        overflowSelect.clickOption(0);
        Test.stopTest();

        Slack.TestHarness.Modal userSelectModal = userSession.getTopModal();
        String modalTitle = userSelectModal.getTitle();

        System.assertEquals('User Select', modalTitle, 'should open User Select modal');
    }

    @isTest
    private static void clickSnoozeMethod_shouldOpenSnoozeMethodModal() {
        MTH_TestSetup.insertCustomSettings();
        Test.startTest();
        mockSetup();
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

        Slack.TestHarness.Overflow overflowSelect = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );
        overflowSelect.clickOption(3);
        Test.stopTest();

        Slack.TestHarness.Modal snoozeModal = userSession.getTopModal();
        String modalTitle = snoozeModal.getTitle();

        System.assertEquals('Change Date Modal', modalTitle, 'should open change date modal');
    }

    @isTest
    private static void clickDeleteMethod_shouldDeleteMethod() {
        MTH_TestSetup.insertCustomSettings();
        Test.startTest();
        mockSetup();
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

        Slack.TestHarness.Overflow overflowSelect = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );
        overflowSelect.clickOption(4);
        Test.stopTest();
        System.assertEquals(1, methodsDaMock.deletedMethodIds.size(), 'should delete method');
    }
    
    private static void mockSetup() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType()),
            Method_Number__c = 200,
            Name = 'Test',
            Tier_1__c = 'Must Use'
        );

        methodDAMock.methods.add(mockMethod);

        Id projectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);

        methodsDaMock.methods.add(new Methods__c(
            Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType), 
            End_Date__c = Date.newInstance(2035, 12, 31),
            PSA_Project__c = projectId,
            Completion_Status__c = 'Complete',
            Method__r = methodDAMock.methods[0]
        ));
        MTH_ManageProjectViewOpen.methodsDa = methodsDaMock;
        methodId = methodsDaMock.methods[0].Id;

        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.SObjectType),
            Slack_User_Id__c = 'mockSlackId'
        );
        UserDataAccessorMock userDaMock = new UserDataAccessorMock();
        userDaMock.usersWSlackData.add(mockUser);

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.SObjectType),
            User_Record__c = userDaMock.usersWSlackData[0].Id
        );
        ContactDataAccessorMock contactDaMock = new ContactDataAccessorMock();
        contactDaMock.contacts.add(mockContact);

        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(new PSA_Project__c(
            Id = projectId
        ));

        ProjectAssignmentDataAccessorMock assignDaMock = new ProjectAssignmentDataAccessorMock();
        assignDaMock.projectAssignments.add(
            new Project_Assignment__c(
                Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
                PSA_Project__c = projectDaMock.projects[0].Id,
                Start_Date__c = Date.newInstance(2022, 1, 1),
                End_Date__c = Date.today(),
                Resource__r = contactDaMock.contacts[0]
            )
        );

        MTH_AppHomeOpen.projectDA = projectDaMock;
        MTH_ManageProjectViewOpen.projectDA = projectDaMock;
        MTH_AppHomeOpen.assignmentDA = assignDaMock;
        MTH_MethodDetailsModalOpen.methodsDA = methodsDaMock;
        MTH_MethodOverflowHandler.methodsDA = methodsDaMock;
        MTH_MethodOverflowHandler.methodDa = methodDAMock;
        MTH_MethodDetailsModalHandler.methodsDA = methodsDaMock;
        MTH_MethodDetailsModalHandler.methodDA = methodDaMock;
        MTH_MethodDetailsModalHandler.psaProjectDA = projectDaMock;
        MTH_MarkCompleteModalHandler.methodsDa = methodsDaMock;
        MTH_UserSelectModalHandler.methodsDA = methodsDaMock;
        MTH_UserSelectModalHandler.projectAssignmentDA = assignDaMock;
        MTH_ProjectSetupModalOpen.psaProjectDA = projectDaMock;
        MTH_SnoozeMethodModalOpen.methodsDA = methodsDaMock;
    }
}