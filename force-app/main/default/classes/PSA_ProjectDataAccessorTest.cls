@isTest
public with sharing class PSA_ProjectDataAccessorTest {

    private static final String TARGETED_CLOUD_NO_CLOUDS_TEST_PROJECT_NAME = 'TargetedCloudsTestProjectNoClouds';
    private static final String TARGETED_CLOUD_OPP_CLOUDS_TEST_PROJECT_NAME = 'TargetedCloudsTestProjectOppClouds';
    private static final String TARGETED_CLOUD_PROJ_CLOUDS_TEST_PROJECT_NAME = 'TargetedCloudsTestProjectProjClouds';

    public static PSA_Project__c buildProject() {
        return new PSA_Project__c(
            End_Date__c = Date.parse('3/21/2023'),
            Name = 'Acme',
            ProjectManagerUser__c = UserInfo.getUserId(),
            Id = 'a393C000000A9WCQA0',
            Engagement_Size__c = 'Large'
            // Id is temporarily hardcoded while it's hardcoded in setup flow
        );
    }

    @TestSetup
    static void targetedCloudSetup(){
        List<PSA_Project__c> testProjects = new List<PSA_Project__c>();

        PSA_Project__c noClouds = new PSA_Project__c(
            Name = PSA_ProjectDataAccessorTest.TARGETED_CLOUD_NO_CLOUDS_TEST_PROJECT_NAME
        );
        testProjects.add(noClouds);

        Opportunity opp = new Opportunity(
            Name = PSA_ProjectDataAccessorTest.TARGETED_CLOUD_OPP_CLOUDS_TEST_PROJECT_NAME,
            Targeted_Clouds__c = 'Comms and Media;Advertising Studio;Analytics for the Rest of Us;App Cloud',
            StageName = '06 - Project Booked',
            CloseDate = Date.parse('3/21/2023')
        );

        insert opp;


        PSA_Project__c projClouds = new PSA_Project__c(
            Name = PSA_ProjectDataAccessorTest.TARGETED_CLOUD_PROJ_CLOUDS_TEST_PROJECT_NAME,
            Targeted_Clouds_Used__c = 'Comms and Media;Competitive Takeout;Connected Services',
            Opportunity__c = opp.Id
        );

        testProjects.add(projClouds);

        PSA_Project__c oppClouds = new PSA_Project__c(
            Name = PSA_ProjectDataAccessorTest.TARGETED_CLOUD_OPP_CLOUDS_TEST_PROJECT_NAME,
            Opportunity__c = opp.Id
        );

        testProjects.add(oppClouds);

        
        insert testProjects;
    }

    @isTest
    public static void getProjectInfo_givenProjectManagerUserId_shouldReturnProjectInfoFields() {
        PSA_Project__c project = buildProject();
        upsert project;

        Test.startTest();
        PSA_Project__c[] returnedProjects = new PSA_ProjectDataAccessor()
            .getPSAProjectByProjectManagerUserId(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(project.Name, returnedProjects[0].Name, 'should return correct project name');
    }

    @isTest
    public static void getProjectInfo_givenProjectId_shouldReturnProjectInfoFields() {
        PSA_Project__c project = buildProject();
        upsert project;
        Set<Id> projectIdSet = new Set<Id>{project.Id};

        Test.startTest();
        PSA_Project__c[] returnedProjects = new PSA_ProjectDataAccessor()
            .getPSAProjectByProjectId(projectIdSet);
        Test.stopTest();

        System.assertEquals(project.Name, returnedProjects[0].Name, 'should return correct project name');
    }

    @isTest
    public static void getProjectAndOpportunityInfo_givenProjectId_shouldReturnProjectAndOpportunityInfoFields() {
        PSA_Project__c project = buildProject();
        upsert project;

        Test.startTest();
        PSA_Project__c[] returnedProjects = new PSA_ProjectDataAccessor().getPSAProjectAndOpportunityByProjectId(new Set<Id>{project.Id});
        Test.stopTest();

        System.assertEquals(project.Name, returnedProjects[0].Name, 'should return correct project name');
    }
    
    @isTest
    public static void getProjectPicklistOptions_givenFieldName_shouldReturnProjectPicklistOptions() {
        
        Test.startTest();
        List<Slack.Option> engagementSizeOptions = new PSA_ProjectDataAccessor().getPSAProjectPicklistOptions('Engagement_Size__c');
        List<Slack.Option> preferredMethodologyOptions = new PSA_ProjectDataAccessor().getPSAProjectPicklistOptions('Preferred_Methodology__c');
        List<Slack.Option> engagementTypeOptions = new PSA_ProjectDataAccessor().getPSAProjectPicklistOptions('Engagement_Type__c');
        Test.stopTest();
        
        System.assert(engagementSizeOptions.size() > 0, 'should return at least one Engagement_Size__c option');
        System.assert(preferredMethodologyOptions.size() > 0, 'should return at least one Preferred_Methodology__c option');
        System.assert(engagementTypeOptions.size() > 0, 'should return at least one Engagement_Type__c option');
    }

    @isTest
    public static void updateProjectFields_givenProjectIdAndFormData_shouldUpdateProjectFields() {
        PSA_Project__c project = buildProject();
        upsert project;

        Map<String, Object> projectFormData = new Map<String, Object>();
        projectFormData.put('engagement_type_select', 'Agile Focused');
        projectFormData.put('verify_engagement_sizing_select', 'Program');
        projectFormData.put('customer_methodology_select', 'Other');

        Test.startTest();
        PSA_Project__c returnedProject = new PSA_ProjectDataAccessor().updateProjectFields(project.Id, projectFormData);
        Test.stopTest();

        System.assertEquals('Agile Focused', returnedProject.Engagement_Type__c, 'should return correct updated engagement type');
    }

    @isTest
    private static void updateProjects_givenProjects_shouldUpdateInDB() {
        PSA_Project__c project = buildProject();
        upsert project;
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        
        projectDaMock.projects.add(new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType),
            Name = 'Test'
        ));

        Test.startTest();
        new PSA_ProjectDataAccessor().updateProjects(new List<PSA_Project__c>{project});
        projectDaMock.updateProjects(projectDaMock.projects);
        Test.stopTest();

        System.assertEquals(
            1,
            projectDaMock.updatedProjects.size(),
            'should update in database'
        );
    }

    @isTest
    private static void getProjectsAndMethods_givenProjectIds_shouldGetCorrectFields() {
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        
        projectDaMock.projects.add(new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        ));

        Test.startTest();
        new PSA_ProjectDataAccessor().getProjectsAndMethodsFromProjectIds(new Set<Id>{projectDaMock.projects[0].Id}, MockSObjectBuilder.getMockId(User.SObjectType));
        PSA_Project__c[] returnedProjects = projectDaMock.getProjectsAndMethodsFromProjectIds(new Set<Id>{projectDaMock.projects[0].Id}, MockSObjectBuilder.getMockId(User.SObjectType));
        Test.stopTest();

        System.assertEquals(
            projectDaMock.projects[0].Id,
            returnedProjects[0].Id,
            'should return correct project Id'
        );
    }

    @isTest
    private static void getProject_givenProjectId_shouldGetCorrectFields() {
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        
        projectDaMock.projects.add(new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        ));

        Test.startTest();
        new PSA_ProjectDataAccessor().getPSAProjectByProjectId(projectDaMock.projects[0].Id);
        PSA_Project__c[] returnedProjects = projectDaMock.getPSAProjectByProjectId(projectDaMock.projects[0].Id);
        Test.stopTest();

        System.assertEquals(
            projectDaMock.projects[0].Id,
            returnedProjects[0].Id,
            'should return correct project Id'
        );
    }

    @isTest
    private static void getProjectsAndMethodsFromProjectIdsStringQuery_givenProjectIdsAndOwner_shouldGetProjectsAndMethodsFromProjectIdsStringQuery() {
        PSA_ProjectDataAccessorMock projectDaMock = new PSA_ProjectDataAccessorMock();
        
        projectDaMock.projects.add(new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
        ));

        Id mockUserId = MockSObjectBuilder.getMockId(User.SObjectType);

        String correctQuery = 'SELECT ' +
                'Id, ' +
                'Name, ' +
                'Start_Date__c, ' +
                'End_Date__c, ' +
                'Project_ID__c, ' +
                'Engagement_Size__c, ' +
                'Engagement_Type__c, ' +
                'Targeted_Clouds_Used__c, ' +
                'Opportunity__r.Targeted_Clouds__c, ' +
                'Preferred_Methodology__c, ' +
                '( ' +
                '    SELECT Id, Method__r.Name, Method__r.Method_Headline__c, End_Date__c, OwnerId ' +
                '    FROM Method_for_Projects__r ' +
                '    WHERE OwnerId = \'' + mockUserId +'\'' +
                ') ' +
                'Other_Preferred_Methodology__c, ' +
                'Project_Management_Tool__c, ' +
                'Other_Project_Management_Tool__c, ' +
                'Work_Management_Tool__c, ' +
                'Other_Work_Management_Tool__c, ' +
                'CICD_Tool__c, ' +
                'Other_CICD_Tool__c, ' +
                'Automated_Testing_Tool__c, ' +
                'Other_Automated_Testing_Tool__c, ' +
                'DAF_Review_Options__c ' +
            'FROM PSA_Project__c ' +
            'WHERE Id IN (\'' + projectDaMock.projects[0].Id + '\') AND (NOT Name LIKE \'Z-%\') ' +
            'WITH SECURITY_ENFORCED';

        Test.startTest();
        String returnedQuery = new PSA_ProjectDataAccessor().getProjectsAndMethodsFromProjectIdsStringQuery(new Set<Id>{projectDaMock.projects[0].Id}, mockUserId);
        Test.stopTest();

        System.assertEquals(correctQuery, returnedQuery,  'should return correct query');
    }

    @isTest
    private static void getPSAProjectTargetedCloudsUsed_givenEmptyOppAndProjectData_shouldReturnEmptyList(){
        
        PSA_Project__c project = [SELECT Id FROM PSA_Project__c where Name=:PSA_ProjectDataAccessorTest.TARGETED_CLOUD_NO_CLOUDS_TEST_PROJECT_NAME];

        Test.startTest();
        List<String> returnedStrings = new PSA_ProjectDataAccessor().getPSAProjectTargetedCloudsUsed(project.Id);
        Test.stopTest();
        System.assertEquals(0, returnedStrings.size(), 'should return an empty list');
    }

    @isTest
    private static void getPSAProjectTargetedCloudsUsed_givenNullProjectId_shouldReturnEmptyList(){
        
        Test.startTest();
        List<String> returnedStrings = new PSA_ProjectDataAccessor().getPSAProjectTargetedCloudsUsed(null);
        Test.stopTest();
        System.assertEquals(0, returnedStrings.size(), 'should return an empty list');
    }

    @isTest
    private static void getPSAProjectTargetedCloudsUsed_shouldReturnProjData(){
        PSA_Project__c project = [SELECT Id FROM PSA_Project__c where Name=:PSA_ProjectDataAccessorTest.TARGETED_CLOUD_PROJ_CLOUDS_TEST_PROJECT_NAME];

        Test.startTest();
        List<String> returnedStrings = new PSA_ProjectDataAccessor().getPSAProjectTargetedCloudsUsed(project.Id);
        Test.stopTest();
        System.assertEquals(3, returnedStrings.size(), 'should return project targeted clouds');
    }

    @isTest
    private static void getPSAProjectTargetedCloudsUsed_givenEmptyProjectData_shouldReturnOppData(){
        
        PSA_Project__c project = [SELECT Id FROM PSA_Project__c where Name=:PSA_ProjectDataAccessorTest.TARGETED_CLOUD_OPP_CLOUDS_TEST_PROJECT_NAME];

        Test.startTest();
        List<String> returnedStrings = new PSA_ProjectDataAccessor().getPSAProjectTargetedCloudsUsed(project.Id);
        Test.stopTest();
        System.assertEquals(4, returnedStrings.size(), 'should return opportunity targeted clouds');
    }
}