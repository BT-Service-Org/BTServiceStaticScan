@isTest
public with sharing class MTH_TestUserSelectModalHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void methodOverflow_givenAssignMethodOptionClicked_shouldOpenModal() {
        MTH_TestSetup.insertCustomSettings();
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(new Methods__c( Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType), Completion_Status__c = 'Complete'));
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(
            (PSA_Project__c) new MockSObjectBuilder(PSA_Project__c.SObjectType)
                .setId()
                .setChild(
                    'Method_for_Projects__r',
                    methodsDaMock.methods[0]
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

        MTH_UserSelectModalHandler.projectAssignmentDA = assignDaMock;
        MTH_UserSelectModalHandler.methodsDA = methodsDaMock;
        
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

        Slack.TestHarness.Overflow methodOverflow = (Slack.TestHarness.Overflow) actionBlock.getComponentByName(
            'overflow',
            Slack.TestHarness.Overflow.class
        );

        Test.startTest();
        methodOverflow.clickOption(0);
        Test.stopTest();

        Slack.TestHarness.Modal newTopModal = userSession.getTopModal();

        System.assertEquals(
            'User Select',
            newTopModal.getTitle(),
            'should open User Select Modal '
        );
    }
}