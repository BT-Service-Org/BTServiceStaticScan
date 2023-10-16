@isTest
public with sharing class MTH_TestAdminModalSubmit {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    private static Slack.TestHarness.Modal getAdminModal() {
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

        Slack.TestHarness.Button openAdminModalButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'open-admin-modal',
            Slack.TestHarness.Button.class
        );

        openAdminModalButton.click();

        return userSession.getTopModal();
    }

    private static Slack.TestHarness.Modal setValues(
        Slack.TestHarness.Modal adminModal,
        String messageIdentifier,
        String mockRecordId
    ) {
        Slack.TestHarness.Input messageSelectInput = (Slack.TestHarness.Input) adminModal.getComponentByName(
            'message-select-input',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.SelectInput messageSelect = (Slack.TestHarness.SelectInput) messageSelectInput.getComponentByName(
            'message-select',
            Slack.TestHarness.SelectInput.class
        );
        messageSelect.setValue(messageIdentifier);

        Slack.TestHarness.Input recordIdInput = (Slack.TestHarness.Input) adminModal.getComponentByName(
            'message-record-id-input',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.TextInput recordIdTextbox = (Slack.TestHarness.TextInput) recordIdInput.getComponentByName(
            'message-record-id',
            Slack.TestHarness.TextInput.class
        );
        recordIdTextbox.setValue((String) mockRecordId);

        return adminModal;
    }

    private static MTH_SlackAppMessengerMock setupMocks() {
        MTH_SlackAppMessengerMock messengerMock = new MTH_SlackAppMessengerMock();
        MTH_AdminModalSubmit.messenger = messengerMock;

        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        MTH_AdminModalSubmit.methodsDA = methodsDaMock;

        ProjectAssignmentDataAccessorMock assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        MTH_AdminModalSubmit.assignmentDa = assignmentDaMock;

        MTH_AdminModalSubmit.hasAdminPermission = true;

        return messengerMock;
    }

    @isTest
    private static void submitAdminModal_givenMethodsDueSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockMethodsId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        setValues(adminModal, 'method-due', mockMethodsId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(1, messengerMock.callsToMethodsDue, 'should call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenMethodsAssignedSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockMethodsId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        setValues(adminModal, 'method-assigned', mockMethodsId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            1,
            messengerMock.callsToMethodsAssigned,
            'should call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenSmartSheetUpdateSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockProjectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);
        setValues(adminModal, 'smartsheet-update', mockProjectId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenKickOffSelectedAndMethodsId_shouldNotSendMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockMethodsId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        setValues(adminModal, 'kick-off', mockMethodsId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenSmartSheetSelectedAndProjectId_shouldNotSendMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockProjectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);
        setValues(adminModal, 'smartsheet-update', mockProjectId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenKickOffSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockProjectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);
        setValues(adminModal, 'kick-off', mockProjectId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(1, messengerMock.callsToKickoff, 'should call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void submitAdminModal_givenSetupSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockProjectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);
        setValues(adminModal, 'setup', mockProjectId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(1, messengerMock.callsToSetup, 'should call setup');
    }

    @isTest
    private static void submitAdminModal_givenWelcomeSelected_shouldSendCorrectMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockProjectId = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType);
        setValues(adminModal, 'welcome', mockProjectId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(
            0,
            messengerMock.callsToSetup,
            'should not call setup'
        );
        System.assertEquals(1, messengerMock.callsToWelcome, 'should call welcome');
    }

    @isTest
    private static void run_givenUserNoPermission_shouldNotSendMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockMethodId = MockSObjectBuilder.getMockId(Method__c.SObjectType);
        setValues(adminModal, 'setup', mockMethodId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();
        
        Test.startTest();
        MTH_AdminModalSubmit.hasAdminPermission = false;
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void run_givenWrongId_shouldNotSendMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        setValues(adminModal, 'setup', 'testfake');
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }

    @isTest
    private static void run_givenWrongIdType_shouldNotSendMessage() {
        Slack.TestHarness.Modal adminModal = getAdminModal();
        Id mockMethodId = MockSObjectBuilder.getMockId(Method__c.SObjectType);
        setValues(adminModal, 'setup', mockMethodId);
        MTH_SlackAppMessengerMock messengerMock = setupMocks();

        Test.startTest();
        adminModal.submit();
        Test.stopTest();

        System.assertEquals(0, messengerMock.callsToMethodsDue, 'should not call methodsDue');
        System.assertEquals(0, messengerMock.callsToKickoff, 'should not call kickoff');
        System.assertEquals(
            0,
            messengerMock.callsToMethodsAssigned,
            'should not call methods assigned'
        );
        System.assertEquals(0, messengerMock.callsToSetup, 'should not call setup');
    }
}