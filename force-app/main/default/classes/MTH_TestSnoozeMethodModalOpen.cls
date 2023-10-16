@isTest
public with sharing class MTH_TestSnoozeMethodModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void snoozeButton_givenButtonClickedAndMethodInDb_shouldOpenModal() {
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

        Slack.TestHarness.Button snoozeButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'open-change-date-modal',
            Slack.TestHarness.Button.class
        );
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(new Methods__c(Start_Date__c = Datetime.now().date()));
        MTH_SnoozeMethodModalOpen.methodsDA = methodsDaMock;

        Test.startTest();
        snoozeButton.click();
        Test.stopTest();

        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();

        System.assertEquals(
            'Change Date Modal',
            newTopModal.getTitle(),
            'should open Change Date Modal'
        );
    }

    @isTest
    static void onCall_givenMethodNotFound_shouldThrowError() {
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        MTH_SnoozeMethodModalOpen.methodsDA = methodsDaMock;

        Boolean correctExceptionThrown = false;

        Test.startTest();
        try {
            new MTH_SnoozeMethodModalOpen.Handler(new Map<String, Object>(), null).call();
        } catch (MTH_SnoozeMethodModalOpen.MethodNotFoundException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, correctExceptionThrown, 'should throw correct exception');
    }
}