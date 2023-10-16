@isTest
public with sharing class ProjectMethodCalculationBatchHandlerTest {
    
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }

    @isTest
    static void testProcessMethodforProjectRecCreation(){
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        List<Methods__c> methods = ProjectMethodTestDataFactory.getMFEsByProjectId(proj.Id);
        delete methods;
        ProjectMethodCalculationsBatchHandler.processMethodforProjectRecCreation(new List<PSA_Project__c>{proj});
        proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        methods = ProjectMethodTestDataFactory.getMFEsByProjectId(proj.Id);
        Assert.areNotEqual( 0, methods.size());

    }

    @isTest
    static void testIsSow(){
        
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);

        List<PSA_Project__c> projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        ProjectMethodCalculationsBatchHandler.projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);

        Assert.isTrue(ProjectMethodCalculationsBatchHandler.isSOW(proj));

        proj.offering__c = null;
        proj.Opportunity__c = null;
        proj.Org62_Opportunity_Id__c = null;
        update proj;

        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        ProjectMethodCalculationsBatchHandler.projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);

        Assert.isFalse(ProjectMethodCalculationsBatchHandler.isSOW(proj));
    }

    @isTest
    static void testGetHandler(){
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);

        List<PSA_Project__c> projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        ProjectMethodCalculationsBatchHandler.projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);

        EDHQ_BT_BaseOfferingHandler handler = ProjectMethodCalculationsBatchHandler.getProcessingHandler(proj);

        Assert.isTrue(handler instanceof EDHQ_BT_CustomerServicesOfferingHandler);

        proj.offering__c = null;
        proj.Opportunity__c = null;
        proj.Org62_Opportunity_Id__c = null;
        update proj;

        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        ProjectMethodCalculationsBatchHandler.projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);


        handler = ProjectMethodCalculationsBatchHandler.getProcessingHandler(proj);

        Assert.isFalse(handler instanceof EDHQ_BT_CustomerServicesOfferingHandler);
        Assert.isFalse(handler instanceof EDHQ_BT_ExpertServicesOfferingHandler);

        
        proj.Org62_Opportunity_Id__c ='a393C000000APJ6QAP';
        update proj;

        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        ProjectMethodCalculationsBatchHandler.projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);
        handler = ProjectMethodCalculationsBatchHandler.getProcessingHandler(proj);
        Assert.isTrue(handler instanceof EDHQ_BT_ExpertServicesOfferingHandler);

    }
}