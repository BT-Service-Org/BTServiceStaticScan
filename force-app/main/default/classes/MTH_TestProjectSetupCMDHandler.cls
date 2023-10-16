@isTest
public with sharing class MTH_TestProjectSetupCMDHandler {
    // Test harness variables
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.UserSession userSession;

    static {
        // Set up test harness and user session
        slackApp = Slack.App.Methodologies.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
    }

    @isTest
    static void testDidCommandOpenModal() {
        Opportunity opp = new Opportunity();
        opp.CreatedDate = Datetime.now();
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Name = 'Test Opp';
        opp.Targeted_Clouds__c = 'Integration Cloud;Core';
        insert opp;

        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;
        project.Opportunity__c = opp.Id;
        update project;

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies-project-setup', 'a393C000000A9WCQA0', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-project-setup-dev', 'a393C000000A9WCQA0', slackApp);
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Test.stopTest();

        System.assertEquals('Project Setup (1 of 4)', modal.getTitle());
    }
}