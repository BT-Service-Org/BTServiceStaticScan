@isTest
public with sharing class MTH_TestOpenAdminModal {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void clickAdminButton_shouldOpenAdminModal() {
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

        Test.startTest();
        openAdminModalButton.click();
        Test.stopTest();

        Slack.TestHarness.Modal newModal = userSession.getTopModal();
        System.assertEquals(
            'Send a message to a user',
            newModal.getTitle(),
            'should open admin modal'
        );
    }
}