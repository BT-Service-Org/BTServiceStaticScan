@isTest
public with sharing class MTH_TestWelcomeMsgCancelButtonHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void welcomeMsgCancelButtonBlockAction_givenButtonPushed_shouldEditMessage() {
        MTH_SlackApiHandlerMock slackApiHandlerMock = new MTH_SlackApiHandlerMock();
        MTH_WelcomeMsgCancelButtonHandler.slackApiHandler = slackApiHandlerMock;
        MTH_WelcomeMsgCancelButtonHandler.ts = 'test';

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
        Slack.TestHarness.Button cancelButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'welcome-message-cancel',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        cancelButton.click();
        Test.stopTest();

        System.assertEquals(
            1,
            slackApiHandlerMock.updateMessageChannelIdTsCalls.size(),
            'should call api to update'
        );
    }
}