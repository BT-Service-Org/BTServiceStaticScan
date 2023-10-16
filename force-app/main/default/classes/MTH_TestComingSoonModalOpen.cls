@isTest
public with sharing class MTH_TestComingSoonModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void clickSearchButtonOnQuickMenu_shouldOpenComingSoonModal() {
        MTH_TestSetup.insertCustomSettings();

        try {
            userSession.executeSlashCommand('/methodologies', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Section searchSection = (Slack.TestHarness.Section) modal.getComponentByName(
            'search-section',
            Slack.TestHarness.Section.class
        );
        Slack.TestHarness.Button searchButton = (Slack.TestHarness.Button) searchSection.getComponentByName(
            'search_all_methods',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        searchButton.click();
        Test.stopTest();

        System.assertEquals(
            'Coming Soon',
            userSession.getTopModal().getTitle(),
            'should open coming soon modal'
        );
    }
}