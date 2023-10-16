@isTest
public with sharing class MTH_TestAddMethodsToManageProject {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void addMethodsButtonClick_shouldAddNewMethodsToManageProjectsScreen() {
        // TODO: Blocked on test coverage for external select with data provider
    }
}