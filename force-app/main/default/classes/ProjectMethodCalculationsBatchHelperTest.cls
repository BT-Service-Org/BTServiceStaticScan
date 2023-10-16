@isTest
public class ProjectMethodCalculationsBatchHelperTest {
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }

    @isTest
    static void testDeleteMfeRecords() {
       
        List<PSA_Project__c> projectList = [SELECT Id FROM PSA_Project__c];
        Set<Id> projectIds = new Set<Id>();
        for(PSA_Project__c proj : projectList){
            projectIds.add(proj.Id);
        }
        List<Methods__c> mfeList = [SELECT Id FROM Methods__c];

        ProjectMethodCalculationsBatchHelper.deleteMfeRecords(projectIds);
        Assert.areNotEqual(0, mfeList.size(), 'Records were deleted as expected');

    }

    @isTest
    static void testGetProjectOfferingMap() {
       
        List <PSA_Project__c> projectList = [SELECT Id,Start_Date__c, End_Date__c, Offering__c, Opportunity__c, Org62_Id__c, Bookings__c, Method_for_Engagement_status__c,Project_Manager__r.User_Record__c, Preferred_Methodology__c, Project_Setup_Status__c, Engagement_Size__c,Org62_Opportunity_Id__c FROM PSA_Project__c];
       
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projectList);
        Map<Id, Practice_Contribution__c> projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projectList);        
        Assert.areNotEqual(0, projectOfferingMap.size(), 'Error');
    }

    @isTest
    static void testFetchRelatedData() {
       
        List<PSA_Project__c> projectList = [SELECT Id,Opportunity__c,Org62_Opportunity_Id__c FROM PSA_Project__c];

        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projectList);
        
        Map<Id, List<Project_Assignment__c>> projectAssgnmentMap = (Map<Id, List<Project_Assignment__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PROJECT_ASSIGNMENT_MAP);
        Assert.areNotEqual(0, projectAssgnmentMap.size(), 'Project Assignment Map is incorrect');

        Map<String, Opportunity> opptyMap = (Map<String, Opportunity>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OPPORTUNITY_MAP);
        Assert.areNotEqual(0, opptyMap.size(), 'Opportunity Map is incorrect');

        Map<Id, List<Stage__c>> playbookStageMap = (Map<Id, List<Stage__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PLAYBOOK_STAGES_MAP);
        Map<Id, List<Method__c>> stageMethodsMap = (Map<Id, List<Method__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_STAGE_METHODS_MAP);
        Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
        Map<String, Practice_Contribution__c> offeringContributionMap = (Map<String, Practice_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_CONTRIBUTION_MAP);
        Map<Id, List<String>> projectOfferingListMap = (Map<Id, List<String>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PROJECT_OFFERING_LIST_MAP);

        Assert.areNotEqual(0, playbookStageMap.size(), 'Playbook Stage Map is incorrect');
        Assert.areNotEqual(0, stageMethodsMap.size(), 'Stage Methods Map  is incorrect');
        Assert.areNotEqual(0, offeringDPOCMap.size(), 'Offering DPOC Map  is incorrect');
        Assert.areNotEqual(0, offeringContributionMap.size(), 'Offering Contribution Map is incorrect');
        Assert.areNotEqual(0, projectOfferingListMap.size(), 'Project Offering List Map is incorrect');

    }
    
    @isTest
    static void tesPopulateDatesInMFEs() {
        
        List<Methods__c> mfeList = [SELECT Id,Start_Date__c,End_Date__c, Method__c, PSA_Project__c FROM Methods__c];
        List <PSA_Project__c> psaProject = [SELECT Id,Start_Date__c, End_Date__c, Offering__c, Opportunity__c, Org62_Id__c, Bookings__c, Method_for_Engagement_status__c,
                                            Project_Manager__r.User_Record__c, ProjectManagerUser__c, Preferred_Methodology__c, Project_Setup_Status__c, Engagement_Size__c,Org62_Opportunity_Id__c FROM PSA_Project__c];
        
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(psaProject);
        ProjectMethodCalculationsBatchHelper.populateDatesInMFEs(mfeList, new Map<Id, PSA_Project__c>(psaProject));
        
        
        for(Methods__c m : mfeList) {
            Date expectedStartDate = System.today() + 7; 
            Date expectedEndDate = expectedStartDate.addDays(10);
            
            Assert.areEqual(expectedStartDate, m.Start_Date__c, 'Records were not produced as expected');
            Assert.areEqual(expectedEndDate, m.End_Date__c, 'Records were not produced as expected');    
        }
        
    }

    @isTest
    static void testCreateMFERecords() {
        
        PSA_Project__c psaProject = [SELECT Id,Opportunity__c FROM PSA_Project__c];
        List<Method__c> methodList = [SELECT Id FROM Method__c];

        ProjectMethodCalculationsBatchHelper.createMFERecords(methodList, psaProject);

        List<Methods__c> methodEngagementList = (List<Methods__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_MFE_LIST);
        Assert.areNotEqual(0, methodEngagementList.size(), 'Not Correct Mfe List');
        Assert.areEqual(MethodologyConstants.PROJECT_STATUS_DONE, psaProject.Method_for_Engagement_status__c, 'Records were not produced as expected');
        
    }

    @isTest
    static void testCalculateTotalScheduleHours() {

        Decimal hours = 0;
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        hours = ProjectMethodCalculationsBatchHelper.calculateTotalScheduleHours(assignmentList, 'Project Manager');
        Assert.areEqual(300.00, hours, 'Records were not produced as expected');
        
    }

    @isTest
    static void testRoleSpecificProjectAssignments() {
        
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        List<Project_Assignment__c> result = ProjectMethodCalculationsBatchHelper.roleSpecificProjectAssignments(assignmentList, 'Project Manager');
        Assert.areNotEqual(0, result.size(), 'Records were not produced as expected');
    }

    @isTest
    static void testCreateMfeRecordsForSOW() {
        
        PSA_Project__c psaProject = [SELECT Id,Engagement_Size__c,Bookings__c,Org62_Opportunity_Id__c FROM PSA_Project__c];
        
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(new List<PSA_Project__c> {psaProject});
        ProjectMethodCalculationsBatchHelper.createMfeRecordsForSOW(psaProject);
        
        PSA_Project__c updatedProj = [SELECT Id, Engagement_Size__c FROM PSA_Project__c WHERE Id = :psaProject.Id];
        Assert.areEqual('Large', updatedProj.Engagement_Size__c, 'Records were not produced as expected');    
        
    }

    @isTest
    static void testGetCountRelatedMethodType(){

        String methodType;
        
        // Test case 1: finalCount <= 28
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(20);
        Assert.areEqual(MethodologyConstants.METHOD_TYPE_MICRO, methodType, 'Expected Result not received');

        // Test case 2: 28 < finalCount <= 42
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(30);
        Assert.areEqual(MethodologyConstants.METHOD_TYPE_SMALL, methodType, 'Expected Result not received');

        // Test case 3: 42 < finalCount <= 60
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(50);
        Assert.areEqual(MethodologyConstants.METHOD_TYPE_MEDIUM, methodType, 'Expected Result not received');

        // Test case 4: 60 < finalCount <= 82
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(70);
        Assert.areEqual(MethodologyConstants.METHOD_TYPE_LARGE, methodType, 'Expected Result not received');

        // Test case 5: 82 < finalCount <= 100
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(100);
        Assert.areEqual(MethodologyConstants.METHOD_TYPE_PROGRAM, methodType, 'Expected Result not received');

        // Test case 6: finalCount > 100
        methodType = ProjectMethodCalculationsBatchHelper.getCountRelatedMethodType(120);
        Assert.areEqual(MethodologyConstants.METHOD_LARGE_SCALE_PROGRAM, methodType, 'Expected Result not received');
    }

    @isTest
    static void testCalculateProjectBookingAmount(){

        Integer projectScore = 0;
        PSA_Project__c psaProject = [SELECT Id,Engagement_Size__c,Bookings__c,Org62_Opportunity_Id__c FROM PSA_Project__c];
        projectScore = ProjectMethodCalculationsBatchHelper.calculateProjectBookingAmount(psaProject);
        Assert.areEqual(24, projectScore, 'Expected Result not received');

    }

    @isTest
    static void testCalculateDLScheduleHours(){

        Integer dlAssignmentScore = 0;
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        dlAssignmentScore = ProjectMethodCalculationsBatchHelper.calculateDLScheduleHours(assignmentList);
        Assert.areEqual(4, dlAssignmentScore, 'Expected Result not received');
    }

    @isTest
    static void testCalculatePMScheduleHours(){

        Integer pmAssignmentScore = 0;
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        pmAssignmentScore = ProjectMethodCalculationsBatchHelper.calculatePMScheduleHours(assignmentList);
        Assert.areEqual(18, pmAssignmentScore, 'Expected Result not received');
    }
    
    @isTest
    static void testCalculateTotalAssignmentScheduleHours(){

        Integer totalAssignmentScore = 0;
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        totalAssignmentScore = ProjectMethodCalculationsBatchHelper.calculateTotalAssignmentScheduleHours(assignmentList);
        Assert.areEqual(30, totalAssignmentScore, 'Expected Result not received');
    }

    @isTest
    static void testCalculateTeamMembersScheduleHours(){

        Decimal result = 0;
        List<Project_Assignment__c> assignmentList = [SELECT Id, PSA_Project__c, Scheduled_Hours__c, Project_Role__c, Start_Date__c, End_Date__c, PSA_Project__r.End_Date__c, PSA_Project__r.Start_Date__c 
                                                        FROM Project_Assignment__c ];

        result = ProjectMethodCalculationsBatchHelper.calculateTeamMembersScheduleHours(assignmentList);
        Assert.areEqual(12, result, 'Expected Result not received');
    }
    

    @isTest
    static void testCalculateTargetedClouds(){

        Integer count = 0;
        PSA_Project__c psaProject = [SELECT Id, Engagement_Size__c, Bookings__c, Org62_Opportunity_Id__c FROM PSA_Project__c];

        ProjectMethodCalculationsBatchHelper.fetchRelatedData(new List<PSA_Project__c> {psaProject});
        count = ProjectMethodCalculationsBatchHelper.calculateTargetedClouds(psaProject);
        Assert.areEqual(4, count, 'Expected Result not received');
    }

}