@isTest
public with sharing class MTH_TestSettingsModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void clickSettingsButtonHomeScreen_shouldOpenSettingsModal() {
        MTH_TestSetup.insertCustomSettings();

        Test.startTest();
        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);

        Slack.TestHarness.Actions actions = (Slack.TestHarness.Actions) home.getComponentByName(
            'header-buttons',
            Slack.TestHarness.Actions.class
        );
        Slack.TestHarness.Button settingsButton = (Slack.TestHarness.Button) actions.getComponentByName(
            'settings-button',
            Slack.TestHarness.Button.class
        );

        settingsButton.click();
        Test.stopTest();

        System.assertEquals(
            'Settings',
            userSession.getTopModal().getTitle(),
            'should open Settings modal'
        );
    }
}