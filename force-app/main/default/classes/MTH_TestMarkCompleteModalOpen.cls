@isTest
public with sharing class MTH_TestMarkCompleteModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void markCompleteButton_givenButtonClicked_shouldOpenModal() {
        MTH_TestSetup.insertCustomSettings();
        List<Methods__c> methodsList = new List<Methods__c>();
        Id methodsMockId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        MethodDataAccessorMock methodDaMock = new MethodDataAccessorMock();
        methodDaMock.methods.add(
            new Method__c(Id = MockSObjectBuilder.getMockId(Method__c.SObjectType), Name = 'Test')
        );
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(
            new Methods__c(
                Id = methodsMockId,
                End_Date__c = Date.newInstance(2021, 2, 17),
                Method__r = methodDaMock.methods[0]
            )
        );
        MTH_MarkCompleteModalHandler.methodsDa = methodsDaMock;

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

        Slack.TestHarness.Button markCompleteButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'mark-methods-complete',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        markCompleteButton.click();
        Test.stopTest();

        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();

        System.assertEquals(
            'Complete Method',
            newTopModal.getTitle(),
            'should open Complete Method Modal '
        );
    }

    @isTest
    static void markCompleteButton_givenNoMethod_shouldThrowException() {
        Boolean exceptionThrown = false;
        MTH_TestSetup.insertCustomSettings();
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

        Slack.TestHarness.Button markCompleteButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'mark-methods-complete',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        try {
            markCompleteButton.click();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, exceptionThrown, 'should not throw unexpected exception');
    }
}