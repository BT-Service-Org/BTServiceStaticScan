@isTest
public with sharing class MTH_TestFeedbackModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void clickFeedbackButtonQuickMenu_shouldOpenFeedbackModal() {
        MTH_TestSetup.insertCustomSettings();

        try {
            userSession.executeSlashCommand('/methodologies', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Section feedbackSection = (Slack.TestHarness.Section) modal.getComponentByName(
            'feedback-section',
            Slack.TestHarness.Section.class
        );
        Slack.TestHarness.Button feedbackButton = (Slack.TestHarness.Button) feedbackSection.getComponentByName(
            'feedback-button',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        feedbackButton.click();
        Test.stopTest();

        System.assertEquals(
            'Digital HQ Feedback',
            userSession.getTopModal().getTitle(),
            'should open feedback  modal'
        );
    }
}