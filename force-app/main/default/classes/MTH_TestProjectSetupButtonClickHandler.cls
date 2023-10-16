@isTest
public with sharing class MTH_TestProjectSetupButtonClickHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void projectSetupButtonOnWelcomeMessage_givenButtonClicked_shouldOpenModal() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        MTH_SlackApiHandlerMock slackApiHandlerMock = new MTH_SlackApiHandlerMock();
        MTH_WelcomeMsgCancelButtonHandler.slackApiHandler = slackApiHandlerMock;
        MTH_WelcomeMsgCancelButtonHandler.ts = 'test';

        try {
            userSession.executeSlashCommand('/methodologies-project-setup', 'a393C000000A9WCQA0', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-project-setup-dev', 'a393C000000A9WCQA0', slackApp);
        }
        
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Actions actionBlock = (Slack.TestHarness.Actions) modal.getComponent(
            0,
            Slack.TestHarness.Actions.class
        );

        Slack.TestHarness.Button welcomeMessageButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'welcome-message-project-setup',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        welcomeMessageButton.click();
        Test.stopTest();

        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();

        System.assertEquals(
            'Project Setup (1 of 4)',
            newTopModal.getTitle(),
            'should open Project Setup Modal 1'
        );
    }
}