public with sharing class EDHQ_BT_ExpertServicesOfferingHandler extends EDHQ_BT_BaseOfferingHandler{
    
    public override void processOffering(PSA_Project__c proj){
        
        proj.Preferred_Methodology__c = MethodologyConstants.METHODOLGY_SPSM_SERVICES_EXPERT_HOURS;
        proj.Offering__c = MethodologyConstants.OFFERING_CUSTOM_SERVICES;
        ProjectMethodCalculationsBatchHelper.createMfeRecordsForSOW(proj);

    }
}