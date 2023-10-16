@isTest
public with sharing class MTH_TestAddMethodsToMethodMgmtModal {
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

    private static void populateExternalSelectAndAddMethod() {
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Input input = (Slack.TestHarness.Input) modal.getInputByLabel(
            'We\'ve identified the following methods for your project. You can add addtional methods by searching below.'
        );
        Slack.TestHarness.ExternalSelect externalSelect = (Slack.TestHarness.ExternalSelect) input.getComponentByName(
            'methods_lookup',
            Slack.TestHarness.ExternalSelect.class
        );

        Slack.TestHarness.Actions actions = (Slack.TestHarness.Actions)modal.getComponentByName('add-methods-to-project', Slack.TestHarness.Actions.class);
        Slack.TestHarness.Button addMethodBtn = (Slack.TestHarness.Button) actions.getComponentByName('add_methods', Slack.TestHarness.Button.class);
        addMethodBtn.click();
    }

    @isTest
    private static void shouldAddMethod_givenMethodFromExternalSelect() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Method__c method = MethodDataAccessorTest.buildMethod('Should Use');
        upsert method;

        try {
            userSession.executeSlashCommand('/methodologies-project-setup', 'a393C000000A9WCQA0', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-project-setup-dev', 'a393C000000A9WCQA0', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        userSession.getTopModal().submit();
        submitPage2();
        Test.startTest();
        populateExternalSelectAndAddMethod();
        Test.stopTest();

        System.assertEquals('Project Setup (3 of 4)', userSession.getTopModal().getTitle(), 'modal refreshes');
    }
}