@isTest
public with sharing class MTH_TestAppHomeOpen {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void openAppHome_shouldHaveNoErrors() {
        Boolean exceptionThrown = false;
        MTH_TestSetup.insertCustomSettings();

        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(
            (PSA_Project__c) new MockSObjectBuilder(PSA_Project__c.SObjectType)
                .setId()
                .setChild(
                    'Method_for_Projects__r',
                    new Methods__c(
                        Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType),
                        End_Date__c = Date.newInstance(2035, 12, 31)
                    )
                )
                .build()
        );
        ProjectAssignmentDataAccessorMock assignDaMock = new ProjectAssignmentDataAccessorMock();
        assignDaMock.projectAssignments.add(
            new Project_Assignment__c(
                Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
                PSA_Project__c = projectDaMock.projects[0].Id,
                Start_Date__c = Date.newInstance(2022, 1, 1),
                End_Date__c = Date.today()
            )
        );
        MTH_AppHomeOpen.projectDA = projectDaMock;
        MTH_AppHomeOpen.assignmentDA = assignDaMock;

        Test.startTest();
        try {
            userSession.openAppHome(slackApp);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, exceptionThrown, 'should not throw exception');
    }
}