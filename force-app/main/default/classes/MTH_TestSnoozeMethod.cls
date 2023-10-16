@isTest
public with sharing class MTH_TestSnoozeMethod {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void snoozeButton_givenButtonClickedAndMethodInDb_shouldOpenModal() {
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(new Methods__c(Start_Date__c = Datetime.now().date()));
        MTH_SnoozeMethodModalOpen.methodsDA = methodsDaMock;
        MTH_SnoozeMethod.methodsDA = methodsDaMock;

        Test.startTest();
        new MTH_SnoozeMethod.Handler(
                new Map<String, Object>(),
                new Slack.RequestContext.Builder()
                    .formData(new Map<String, Object>{ 'changeDate' => '2023-02-15' })
                    .build()
            )
            .run();
        Test.stopTest();

        System.assertEquals(1, methodsDaMock.updatedMethods.size(), 'should update methods in db');
    }

    @isTest
    static void onCall_givenMethodNotFound_shouldThrowError() {
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        MTH_SnoozeMethod.methodsDA = methodsDaMock;

        Boolean correctExceptionThrown = false;

        Test.startTest();
        try {
            new MTH_SnoozeMethod.Handler(new Map<String, Object>(), null).run();
        } catch (MTH_SnoozeMethod.MethodsNotFoundException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, correctExceptionThrown, 'should throw correct exception');
    }
}