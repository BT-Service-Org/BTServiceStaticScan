@isTest
public with sharing class MTH_TestFeedbackModalSubmit {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void submitOnFirstModal_shouldOpenNextModalOnSubmit() {
        MTH_TestSetup.insertCustomSettings();
        MTH_SlackApiHandlerMock slackApiMock = new MTH_SlackApiHandlerMock();
        MTH_FeedbackModalSubmit.slackApi = slackApiMock;

        try {
            userSession.executeSlashCommand('/methodologies', 'feedback', slackApp);
        } catch (Exception e) {
            userSession.executeSlashCommand('/methodologies-dev', 'feedback', slackApp);
        }
        Slack.TestHarness.Modal modal = userSession.getTopModal();

        Slack.TestHarness.Input radioInput = (Slack.TestHarness.Input) modal.getComponentByName(
            'radio-input',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.RadioGroup radioGroup = (Slack.TestHarness.RadioGroup) radioInput.getComponentByName(
            'quantitative-feedback',
            Slack.TestHarness.RadioGroup.class
        );
        List<Slack.TestHarness.Option> options = radioGroup.getOptions();
        radioGroup.setValue(options[0].getIdentifier());

        Slack.TestHarness.Input textInput = (Slack.TestHarness.Input) modal.getComponentByName(
            'text-input',
            Slack.TestHarness.Input.class
        );
        Slack.TestHarness.TextInput textBox = (Slack.TestHarness.TextInput) textInput.getComponentByName(
            'text-feedback',
            Slack.TestHarness.TextInput.class
        );
        textBox.setValue('test test test');

        Test.startTest();
        modal.submit();
        Test.stopTest();

        System.assertEquals(1, slackApiMock.channelsSentMessage.size(), 'should call slack api');
    }
}