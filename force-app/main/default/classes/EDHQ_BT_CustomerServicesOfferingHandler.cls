public with sharing class EDHQ_BT_CustomerServicesOfferingHandler extends EDHQ_BT_BaseOfferingHandler {

    public override void processOffering(PSA_Project__c proj){
        if(String.isBlank(proj.Preferred_Methodology__c)){
            proj.Preferred_Methodology__c = MethodologyConstants.METHODOLGY_SPSM_PROJECT;
        }
        
        if(proj.Preferred_Methodology__c == MethodologyConstants.METHODOLGY_SPSM_PROJECT){
            ProjectMethodCalculationsBatchHelper.createMfeRecordsForSOW(proj);
        }
        else{
            DHQ_Product_Offering_Contribution__c defaultDpoc = (DHQ_Product_Offering_Contribution__c)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_DEFAULT_DPOC);
            createMFERecordsForDPOC(defaultDpoc, proj);
        }

    }
}