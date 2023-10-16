@isTest
public with sharing class MTH_TestMarkMethodComplete {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    static void markCompleteButton_givenButtonClicked_shouldOpenModal() {
        MTH_TestSetup.insertCustomSettings();
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

        Slack.TestHarness.Button markCompleteButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'mark-methods-complete',
            Slack.TestHarness.Button.class
        );

        MethodDataAccessorMock methodDaMock = new MethodDataAccessorMock();
        methodDaMock.methods.add(new Method__c(Id = MockSObjectBuilder.getMockId(Method__c.SObjectType), Name = 'Test'));
        
        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        );
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(mockProject);
        MTH_ManageProjectViewOpen.projectDA = projectDaMock;

        ProjectAssignmentDataAccessorMock paDaMock = new ProjectAssignmentDataAccessorMock();
        MTH_MarkMethodComplete.assignmentDA = paDaMock;
        Project_Assignment__c mockProjectAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType)
        );
        paDaMock.projectAssignments.add(mockProjectAssignment);


        Id methodsMockId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(new Methods__c(Id = methodsMockId, End_Date__c = Date.newInstance(2021, 2, 17), Method__r = methodDaMock.methods[0], PSA_Project__r = mockProject));
        MTH_MarkCompleteModalHandler.methodsDa = methodsDaMock;
        MTH_MarkMethodComplete.methodsDA = methodsDaMock;
        MTH_ManageProjectViewOpen.methodsDA = methodsDaMock;

        markCompleteButton.click();
        Slack.TestHarness.Modal markCompleteModal = userSession.getTopModal();

        Test.startTest();
        markCompleteModal.submit();
        Test.stopTest();

        System.assertEquals(1, methodsDaMock.updatedMethods.size(), 'should update to db');
        Methods__c updatedMethod = methodsDaMock.updatedMethods[0];
        System.assertEquals(
            'Complete',
            updatedMethod.Completion_Status__c,
            'should mark method as complete'
        );
        System.assertEquals(
            methodsMockId,
            updatedMethod.Id,
            'should update same method as retrieved'
        );
    }
}