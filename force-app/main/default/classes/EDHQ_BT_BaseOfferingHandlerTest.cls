@isTest
public with sharing class EDHQ_BT_BaseOfferingHandlerTest {
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }

    @isTest
    static void testProcessOffering(){
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        String newOrg62OppId = 'a393C000000APJ6QAT';

        ProjectMethodTestDataFactory.createOpp(newOrg62OppId);

        Practice_Contribution__c oc4 = new Practice_Contribution__c();
        oc4.Name = 'Test 1';
        oc4.Offering__c = MethodologyConstants.OFFERING_PHASE_0_STRATEGIC_PLANNING;
        oc4.Work_Units__c = 'Business Value Mapping';
        oc4.Org62_Opportunity_Id__c = newOrg62OppId;

        insert oc4;

        proj.Offering__c = MethodologyConstants.OFFERING_PHASE_0_STRATEGIC_PLANNING;
        proj.Org62_Opportunity_Id__c = newOrg62OppId;
        update proj;

        EDHQ_BT_BaseOfferingHandler handler = new EDHQ_BT_BaseOfferingHandler();

        List<PSA_Project__c> projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);

        handler.processOffering(proj);
        verifyMFEs();
    }

    @isTest
    static void testProcessOfferingForCustomServices(){
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        proj.Preferred_Methodology__c = null;
        update proj;

        EDHQ_BT_BaseOfferingHandler handler = new EDHQ_BT_CustomerServicesOfferingHandler();
        List<PSA_Project__c> projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        handler.processOffering(proj);
        verifyMFEs();
        Assert.areEqual(MethodologyConstants.METHODOLGY_SPSM_PROJECT,proj.Preferred_Methodology__c );

        proj.Preferred_Methodology__c = 'other';
        update proj;

        proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        handler.processOffering(proj);
        verifyMFEs();
    }

    @isTest
    static void testProcessOfferingForExpertServices(){
        PSA_Project__c proj = ProjectMethodTestDataFactory.getProject(ProjectMethodTestDataFactory.PROJECT_NAME);
        EDHQ_BT_BaseOfferingHandler handler = new EDHQ_BT_ExpertServicesOfferingHandler();
        List<PSA_Project__c> projList = new List<PSA_Project__c>{proj};
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        handler.processOffering(proj);

        Assert.areEqual(MethodologyConstants.METHODOLGY_SPSM_SERVICES_EXPERT_HOURS, proj.Preferred_Methodology__c);
        Assert.areEqual(MethodologyConstants.OFFERING_CUSTOM_SERVICES, proj.offering__c);
        verifyMFEs();
    }


    private static void verifyMFEs(){
        List<Methods__c> mfeRecords = (List<Methods__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_MFE_LIST);
        Assert.areNotEqual(null, mfeRecords);
        Assert.areNotEqual( 0, mfeRecords.size());
    }
}