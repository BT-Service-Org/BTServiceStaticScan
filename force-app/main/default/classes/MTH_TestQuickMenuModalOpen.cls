@isTest
public with sharing class MTH_TestQuickMenuModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void clickHelpButtonHomeScreen_shouldOpenQuickMenu() {
        MTH_TestSetup.insertCustomSettings();
        
        Test.startTest();

        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);

        Slack.TestHarness.Actions actions = (Slack.TestHarness.Actions) home.getComponentByName(
            'header-buttons',
            Slack.TestHarness.Actions.class
        );
        Slack.TestHarness.Button helpButton = (Slack.TestHarness.Button) actions.getComponentByName(
            'help-button',
            Slack.TestHarness.Button.class
        );

        helpButton.click();
        Test.stopTest();

        System.assertEquals(
            'Quick Menu',
            userSession.getTopModal().getTitle(),
            'should open quick menu modal'
        );
    }
}