@isTest
public with sharing class MTH_TestErrorModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void callingOpenModalMethod_shouldOpenErrorModal() {
        MTH_TestSetup.insertCustomSettings();
        try {
            userSession.executeSlashCommand('/methodologies', 'openTestModal', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'openTestModal', slackApp);
        }

        Slack.TestHarness.Modal testModal = userSession.getTopModal();
        Slack.TestHarness.Actions actionBlock = (Slack.TestHarness.Actions) testModal.getComponent(
            0,
            Slack.TestHarness.Actions.class
        );

        Slack.TestHarness.Button openErrorModalButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'open-error-modal',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        openErrorModalButton.click();
        Test.stopTest();
        
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        
        System.assertEquals(
            'An error has occurred',
            modal.getTitle(),
            'should open error modal'
        );
    }
}