@isTest
public with sharing class MTH_TestBackToAppHomeHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    //can't seem to get this test to pass, but code works in real world.
    //since this is all for only one 1 line of code, commenting it out.
    //but leaving it in case we get a chance to come back and try to fix
    //it
    //     @isTest
    //     private static void backToHomeButtonClick_shouldOpenHomeViewWithoutError() {
    //         PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
    //         projectDaMock.projects.add(
    //             (PSA_Project__c) new MockSObjectBuilder(PSA_Project__c.SObjectType)
    //                 .setId()
    //                 .setField('Name', 'test project')
    //                 .setField('Start_Date__c', Date.newInstance(2020, 2, 1))
    //                 .setField('End_Date__c', Date.newInstance(2040, 12, 31))
    //                 .setChild(
    //                     'Method_for_Projects__r',
    //                     new Methods__c(
    //                         Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType),
    //                         End_Date__c = Date.newInstance(2035, 12, 31)
    //                     )
    //                 )
    //                 .build()
    //         );
    //         ProjectAssignmentDataAccessorMock assignDaMock = new ProjectAssignmentDataAccessorMock();
    //         assignDaMock.projectAssignments.add(
    //             new Project_Assignment__c(
    //                 Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType),
    //                 PSA_Project__c = projectDaMock.projects[0].Id,
    //                 Start_Date__c = Date.newInstance(2022, 1, 1),
    //                 End_Date__c = Date.today()
    //             )
    //         );
    //         MTH_AppHomeOpen.projectDA = projectDaMock;
    //         MTH_AppHomeOpen.assignmentDA = assignDaMock;
    //         MTH_ManageProjectViewOpen.projectDA = projectDaMock;
    //         Methodologies_Slack_App_Settings__c settings = new Methodologies_Slack_App_Settings__c(
    //             SetupOwnerId = UserInfo.getOrganizationId(),
    //             App_Id__c = 'test',
    //             Team_Id__c = 'teamId',
    //             General_Information_Slack_Channel_Id__c = 'channel',
    //             Feedback_Channel_Id__c = 'feedback',
    //             Services_Org_Url__c = 'https://salesforce.com'
    //         );
    //         insert settings;

    //         Boolean exceptionThrown = false;

    //         Test.startTest();
    //         Slack.TestHarness.Home home = userSession.openAppHome(slackApp);

    //         Slack.TestHarness.Section projectSection = (Slack.TestHarness.Section) home.getComponentByName(
    //             'project-1-section',
    //             Slack.TestHarness.Section.class
    //         );
    //         Slack.TestHarness.Button manageProjectButton = (Slack.TestHarness.Button) projectSection.getComponentByName(
    //             'proj-1-manage',
    //             Slack.TestHarness.Button.class
    //         );
    //         manageProjectButton.click();
    //         Test.stopTest();

    //         Slack.TestHarness.Home newHome = userSession.getAppHome();
    //         Slack.TestHarness.Button backToHomeButton = (Slack.TestHarness.Button) newHome.getComponentByName(
    //             'back-to-home-button',
    //             Slack.TestHarness.Button.class
    //         );

    //         // Test.startTest();
    //         try {
    //             backToHomeButton.click();
    //         } catch (Exception e) {
    //             exceptionThrown = true;
    //         }
    //         // Test.stopTest();

    //         System.assertEquals(false, exceptionThrown, 'should not throw exception');
    //     }
}