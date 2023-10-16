@isTest
public with sharing class MTH_TestMethodinSOWHandler {
    private static Slack.App slackApp = Slack.App.Methodologies.get();
    private static Slack.TestHarness testHarness = new Slack.TestHarness();
    private static Slack.TestHarness.State slackState = testHarness.getNewSlackState();
    private static Slack.TestHarness.UserSession userSession = slackState.createUserSession();

    @isTest
    private static void pressingButtonWhenFalse_shouldUpdateModal(){
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

        Slack.TestHarness.Button sowButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'sow_star',
            Slack.TestHarness.Button.class
        );

        Method__c method = new Method__c(Id = MockSObjectBuilder.getMockId(Method__c.SObjectType), Name = 'Test');

        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        Methods__c methods = new Methods__c(Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType), Method__r = method);
        methodsDaMock.methods.add(methods);
        
        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        );
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(mockProject);
        MTH_PaginationMock paginatorMock = new MTH_PaginationMock();
        paginatorMock.pageMap.put(1, new List<SObject>{(SObject) methods}); 
        MTH_MethodinSOWHandler.projectDA = projectDaMock;
        MTH_MethodinSOWHandler.paginator = paginatorMock;
        MTH_MethodinSOWHandler.methodsDA = methodsDaMock;



        Test.startTest();
        sowButton.click();
        Test.stopTest();

        System.assertEquals('Project Setup (4 of 4)', userSession.getTopModal().getTitle(), 'modal should update with correct title');
    }

    @isTest
    private static void pressingButtonWhenTrue_shouldUpdateModal(){
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

        Slack.TestHarness.Button sowButton = (Slack.TestHarness.Button) actionBlock.getComponentByName(
            'sow_star',
            Slack.TestHarness.Button.class
        );

        Method__c method = new Method__c(Id = MockSObjectBuilder.getMockId(Method__c.SObjectType), Name = 'Test');

        MethodsDataAccessorMock methodsDaMock = new MethodsDataAccessorMock();
        Methods__c methods = new Methods__c(Id = MockSObjectBuilder.getMockId(Methods__c.SObjectType), Method_in_SOW__c = true, Method__r = method);
        methodsDaMock.methods.add(methods);
        
        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        );
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        projectDaMock.projects.add(mockProject);
        MTH_PaginationMock paginatorMock = new MTH_PaginationMock();
        paginatorMock.pageMap.put(1, new List<SObject>{(SObject) methods}); 
        MTH_MethodinSOWHandler.projectDA = projectDaMock;
        MTH_MethodinSOWHandler.paginator = paginatorMock;
        MTH_MethodinSOWHandler.methodsDA = methodsDaMock;



        Test.startTest();
        sowButton.click();
        Test.stopTest();

        System.assertEquals('Project Setup (4 of 4)', userSession.getTopModal().getTitle(), 'modal should update with correct title');
    }
}