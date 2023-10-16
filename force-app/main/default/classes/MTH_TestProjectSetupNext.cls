@isTest
public with sharing class MTH_TestProjectSetupNext {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();
    private static PSA_Project__c project;
    private static MTH_SlackChannelSetupMock slackChannelSetupMock;

    private static void submitStartModal() {
        userSession.getTopModal().submit();
    }

    private static void submtMethodsModal() {
        userSession.getTopModal().submit();
    }

    private static void submitOtherDetailsModal(){
        Slack.TestHarness.Modal modal = userSession.getTopModal();

        Slack.TestHarness.Input detailInput = (Slack.TestHarness.Input) userSession.getTopModal().getComponentByName('other_work_management_tool_block', Slack.TestHarness.Input.class);

        Slack.TestHarness.TextInput txtInput = (Slack.TestHarness.TextInput) detailInput.getComponentByName(
            'other_work_management_tool',
            Slack.TestHarness.TextInput.class
        );

        txtInput.setValue('Other work management tool');

        modal.submit();
    }

    private static void submitSowModal() {
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

        Slack.TestHarness.Input inputLink = (Slack.TestHarness.Input) modal.getComponentByName(
            'sow_link_block',
            Slack.TestHarness.Input.class
        );

        Slack.TestHarness.TextInput txtInput = (Slack.TestHarness.TextInput) inputLink.getComponentByName(
            'org62_sow_link',
            Slack.TestHarness.TextInput.class
        );

        checkbox1.toggleValue();
        checkbox2.toggleValue();
        txtInput.setValue('https://example.com');
        modal.submit();
    }

    private static void submitSlackModal() {
        Slack.TestHarness.Modal modal = userSession.getTopModal();

        Slack.TestHarness.Input inputAccChannel = (Slack.TestHarness.Input) modal.getComponentByName(
            'account_channel_block',
            Slack.TestHarness.Input.class
        );

        Slack.TestHarness.ConversationsSelect channelSelect = (Slack.TestHarness.ConversationsSelect) inputAccChannel.getComponentByName(
            'account_channel_id',
            Slack.TestHarness.ConversationsSelect.class
        );

        List<Slack.TestHarness.Option> channels = channelSelect.getOptions();
        channelSelect.setValue(channels.get(0).getIdentifier());

        Slack.TestHarness.Input inputSpwLink = (Slack.TestHarness.Input) modal.getComponentByName(
            'spw_link_block',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.TextInput spwTxtInput = (Slack.TestHarness.TextInput) inputSpwLink.getComponentByName(
            'spw_link',
            Slack.TestHarness.TextInput.class
        );

        spwTxtInput.setValue('https://example.com');

        modal.submit();
    }

    private static void setup() {
        setup(false);
    }

    private static void setup(Boolean withOthers) {
        project = new PSA_Project__c(
            End_Date__c = Date.parse('3/21/2023'),
            Name = 'Acme',
            Engagement_Size__c = 'Large',
            Engagement_Type__c = 'Waterfall Focused',
            Targeted_Clouds_Used__c = 'App Cloud',
            Preferred_Methodology__c = 'SPSM - Project',
            Project_Management_Tool__c = 'Smartsheet (DHQ Created)'
        );
        if (withOthers) {
            project.Work_Management_Tool__c = 'Other - please specify';
        }
        upsert project;

        Method__c method = MethodDataAccessorTest.buildMethod('Should Use');
        upsert method;

        slackChannelSetupMock = new MTH_SlackChannelSetupMock();
        MTH_ProjectSetupNext.channelSetup = slackChannelSetupMock;
    }

    @isTest
    private static void submitOnStartModal_shouldOpenNextModalOnSubmit() {
        setup();

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }
        submitStartModal();
        Test.stopTest();

        System.assertEquals('Project Setup (2 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void submitOnStartModal_shouldOpenDetailsModalOnSubmit() {
        setup(true);

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }
        submitStartModal();
        Test.stopTest();

        System.assertEquals('Project Setup (1 of 4)', userSession.getTopModal().getTitle());
        Slack.TestHarness.Input detailInput = (Slack.TestHarness.Input) userSession.getTopModal().getComponentByName('other_work_management_tool_block', Slack.TestHarness.Input.class);
        System.assertNotEquals(null, detailInput);
    }

    @isTest
    private static void submitOnDetailsModal_shouldOpenSowModalOnSubmit() {
        setup(true);

        Test.startTest();
        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }

        submitStartModal();
        submitOtherDetailsModal();
        Test.stopTest();

        System.assertEquals('Project Setup (2 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void submitOnSowModal_shouldOpenNextModalOnSubmit() {
        setup();

        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();

        submitStartModal();

        Test.startTest();
        submitSowModal();
        Test.stopTest();

        System.assertEquals('Project Setup (3 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void submitOnMethodsModal_shouldOpenNextModalOnSubmit() {
        setup();

        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }

        submitStartModal();
        submitSowModal();

        Test.startTest();
        submtMethodsModal();
        Test.stopTest();

        System.assertEquals('Project Setup (4 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void clickingNextOnMethodsModal_shouldPaginateMethods() {
        setup();

        List<Methods__c> methodsList = new List<Methods__c>();

        for (Integer i = 0; i < 30; i++) {
            Methods__c methods = new Methods__c();
            methods.PSA_Project__c = project.Id;
            methodsList.add(methods);
        }

        insert methodsList;

        try {
            userSession.executeSlashCommand('/methodologies', 'openTestModal', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'openTestModal', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Actions actionBlock = (Slack.TestHarness.Actions) modal.getComponent(
            0,
            Slack.TestHarness.Actions.class
        );

        Slack.TestHarness.Button nextBtn = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'next_page',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        nextBtn.click();
        Test.stopTest();

        System.assertEquals('Project Setup (3 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void clickingPreviousOnMethodsModal_shouldPaginateMethods() {
        setup();

        List<Methods__c> methodsList = new List<Methods__c>();

        for (Integer i = 0; i < 40; i++) {
            Methods__c methods = new Methods__c();
            methods.PSA_Project__c = project.Id;
            methodsList.add(methods);
        }

        insert methodsList;

        try {
            userSession.executeSlashCommand('/methodologies', 'openTestModal', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'openTestModal', slackApp);
        }

        Slack.TestHarness.Modal modal = userSession.getTopModal();
        Slack.TestHarness.Actions actionBlock = (Slack.TestHarness.Actions) modal.getComponent(
            0,
            Slack.TestHarness.Actions.class
        );

        Slack.TestHarness.Button previousBtn = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'previous_page',
            Slack.TestHarness.Button.class
        );

        Test.startTest();
        previousBtn.click();
        Test.stopTest();

        System.assertEquals('Project Setup (3 of 4)', userSession.getTopModal().getTitle());
    }

    @isTest
    private static void submitOnSlackModal_shouldOpenNextModalOnSubmit() {
        setup();

        try {
            userSession.executeSlashCommand('/methodologies-project-setup', project.Id, slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand(
                '/methodologies-project-setup-dev',
                project.Id,
                slackApp
            );
        }

        submitStartModal();
        submitSowModal();
        submtMethodsModal();

        Test.startTest();
        submitSlackModal();
        Test.stopTest();

        System.assertEquals('What\'s Next?', userSession.getTopModal().getTitle());
    }

    // Unable to get this test passing
    // @isTest
    // private static void submitOnFourthModal_shouldOpenQuickMenuOnSubmit() {
    //     MTH_TestSetup.insertCustomSettings();
    //     PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
    //     upsert project;

    //     Method__c method = MethodDataAccessorTest.buildMethod('Should Use');
    //     upsert method;

    //     try {
    //         userSession.executeSlashCommand('/methodologies-project-setup', 'a393C000000A9WCQA0', slackApp);
    //     } catch (Exception e) {
    //         userSession.executeSlashCommand('/methodologies-project-setup-dev', 'a393C000000A9WCQA0', slackApp);
    //     }
    //     userSession.getTopModal().submit();
    //     submitPage2();
    //     userSession.getTopModal().submit();

    //     Test.startTest();
    //     userSession.getTopModal().submit();
    //     Test.stopTest();

    //     System.assertEquals('What\'s Next?', userSession.getTopModal().getTitle());
    // }
}