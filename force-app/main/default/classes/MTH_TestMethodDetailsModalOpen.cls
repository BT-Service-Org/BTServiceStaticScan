@isTest
public with sharing class MTH_TestMethodDetailsModalOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void snoozeButton_givenButtonClickedAndMethodInDb_shouldOpenModal() {
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

        Slack.TestHarness.Button viewDetailsButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'open-view-details-modal',
            Slack.TestHarness.Button.class
        );
        Method__c method = MethodDataAccessorTest.buildMethod('Won\'t Use');

        //can't mock this because the data accessor is directly referenced in the Slack view
        insert method;
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(
            new Methods__c(End_Date__c = Datetime.now().date(), Method__c = method.Id)
        );
        MTH_MethodDetailsModalOpen.methodsDA = methodsDaMock;
        MTH_MethodDetailsModalHandler.methodsDa = methodsDaMock;

        Test.startTest();
        viewDetailsButton.click();
        Test.stopTest();

        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();

        System.assertEquals(
            'Method #246',
            newTopModal.getTitle(),
            'should open Method Details Modal'
        );
    }
}