@isTest
public with sharing class MTH_TestProjectSetupMethodsFilter {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    private static void submitPage2() {
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Input input1 = (Slack.TestHarness.Input) modal.getComponentByName(
            'confirmation_checkbox1',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.Checkbox checkbox1 = (Slack.TestHarness.Checkbox) input1.getComponentByName(
            'sow_box',
            Slack.TestHarness.Checkbox.class
        );

        Slack.TestHarness.Input input2 = (Slack.TestHarness.Input) modal.getComponentByName(
            'confirmation_checkbox2',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.Checkbox checkbox2 = (Slack.TestHarness.Checkbox) input2.getComponentByName(
            'resources_box',
            Slack.TestHarness.Checkbox.class
        );
        
        checkbox1.toggleValue();
        checkbox2.toggleValue();
        modal.submit();
    }

    @isTest
    private static void selectingMethodsOption_shouldUpdateModal() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Method__c method = MethodDataAccessorTest.buildMethod('Should Use');
        insert method;

        Methods__c methods = MethodsDataAccessorTest.buildMethods(project.Id, 'Complete', 2024);
        methods.Method__r = method;
        insert methods;


        try {
            userSession.executeSlashCommand('/methodologies-project-setup', 'a393C000000A9WCQA0', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-project-setup-dev', 'a393C000000A9WCQA0', slackApp);
        }
        userSession.getTopModal().submit();
        submitPage2();
        userSession.getTopModal().submit();
        Slack.TestHarness.SelectInput selectInput = (Slack.TestHarness.SelectInput) userSession.getTopModal().getInputByLabel('Search:').getComponentByName('methods_lookup', Slack.TestHarness.SelectInput.class);

        Test.startTest();
        selectInput.setValue(methods.Id);
        Test.stopTest();
        
        String modalTitle = userSession.getTopModal().getTitle();
        
        System.assertEquals('Project Setup (4 of 4)', modalTitle, 'modal should update with correct title');
    }
}