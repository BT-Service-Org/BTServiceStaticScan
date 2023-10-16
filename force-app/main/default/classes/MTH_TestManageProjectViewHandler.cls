@isTest
public with sharing class MTH_TestManageProjectViewHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void manageProjectButtonClick_shouldOpenManageProjectHomeViewWithoutErrors() {
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
        MTH_ManageProjectViewOpen.projectDA = projectDaMock;
        MTH_AppHomeOpen.assignmentDA = assignDaMock;
        List<Methods__c> methodsList = new List<Methods__c>();
        Id methodsMockId = MockSObjectBuilder.getMockId(Methods__c.SObjectType);
        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        methodsDaMock.methods.add(new Methods__c(Id = methodsMockId, Completion_Status__c = 'Complete'));
        methodsDaMock.methods.add(new Methods__c(Id = methodsMockId, End_Date__c = Date.newInstance(2021, 2, 17)));
        methodsDaMock.methods.add(new Methods__c(Id = methodsMockId, End_Date__c = Date.newInstance(2023, 12, 20)));
        methodsDaMock.methods.add(new Methods__c(Id = methodsMockId));
        MTH_ManageProjectViewOpen.methodsDa = methodsDaMock;
        
        Test.startTest();
        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);
        System.debug(home);
        Slack.TestHarness.Section projectSection = (Slack.TestHarness.Section) home.getComponentByName(
            'project-1-section',
            Slack.TestHarness.Section.class
        );
        Slack.TestHarness.Button manageProjectButton = (Slack.TestHarness.Button) projectSection.getComponentByName(
            'proj-1-manage',
            Slack.TestHarness.Button.class
        );
        manageProjectButton.click();
        Test.stopTest();
        
        Slack.TestHarness.Home manageProjectHome = userSession.getAppHome();
        Integer homeComponentCount = manageProjectHome.getComponentCount();

        System.assert(homeComponentCount > 0, 'home should have multiple components');
    }

}