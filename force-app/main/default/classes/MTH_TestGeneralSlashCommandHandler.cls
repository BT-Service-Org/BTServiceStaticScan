@isTest
public with sharing class MTH_TestGeneralSlashCommandHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void generalSlashCommand_givenTestModalParam_shouldOpenTestModal() {
        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies', 'openTestModal', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'openTestModal', slackApp);
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Test.stopTest();

        System.assertEquals('Test Modal', modal.getTitle(), 'should open test modal');
    }

    @isTest
    static void generalSlashCommand_givenNoParam_shouldOpenQuickMenu() {
        MTH_TestSetup.insertCustomSettings();

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', slackApp);
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Test.stopTest();

        System.assertEquals('Quick Menu', modal.getTitle(), 'should open quick menu modal');
    }

    @isTest
    static void generalSlashCommand_givenFeedbackParam_shouldOpenFeedbackModal() {
        MTH_TestSetup.insertCustomSettings();

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies', 'feedback', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'feedback', slackApp);
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Test.stopTest();

        System.assertEquals('Digital HQ Feedback', modal.getTitle(), 'should open feedback modal');
    }
}