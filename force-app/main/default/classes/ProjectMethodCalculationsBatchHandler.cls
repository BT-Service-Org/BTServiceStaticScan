public with sharing class ProjectMethodCalculationsBatchHandler {
    
    public static Map<Id, Practice_Contribution__c> projectOfferingMap;
    @InvocableMethod(label = 'Auto Create MFEs')
    public static void processMethodforProjectRecCreation(List<PSA_Project__c> projList){
        ProjectMethodCalculationsBatchHelper.fetchRelatedData(projList);
        projectOfferingMap = ProjectMethodCalculationsBatchHelper.getProjectOfferingMap(projList);
        Set<Id> projectIdsToBeRefreshed = new Set<Id>();
        List<PSA_Project__c> projListToBeProcessed = new List<PSA_Project__c>();
        for (PSA_Project__c proj : projList){
            if(shouldRunProcess(proj)){
                projectIdsToBeRefreshed.add(proj.id);
                projListToBeProcessed.add(proj);
            }
        }

        ProjectMethodCalculationsBatchHelper.deleteMfeRecords(projectIdsToBeRefreshed);

        for (PSA_Project__c proj : projListToBeProcessed){
            Practice_Contribution__c oc = projectOfferingMap.get(proj.Id);
            if(oc != null){
                proj.Offering__c = oc.Offering__c;
                proj.Offering_Contribution__c = oc.Id;
            }  
            EDHQ_BT_BaseOfferingHandler handler = getProcessingHandler(proj);

            handler.processOffering(proj);
        }

        List<Methods__c> mfeRecords = (List<Methods__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_MFE_LIST);
        if(mfeRecords!=null && !mfeRecords.isEmpty()){
            ProjectMethodCalculationsBatchHelper.populateDatesInMFEs(mfeRecords, new Map<Id, PSA_Project__c>(projListToBeProcessed));
            Database.insert(mfeRecords, false);
        }
        if(!projListToBeProcessed.isEmpty() && System.isBatch()){
            Database.update(projListToBeProcessed, false);
        }

    }

    public static boolean shouldRunProcess(PSA_Project__c proj){
        return !System.isBatch() || isSOW(proj) || proj.Method_for_Engagement_status__c == MethodologyConstants.PROJECT_STATUS_REFRESH || proj.Method_for_Engagement_status__c == MethodologyConstants.PROJECT_STATUS_NOT_STARTED; 
    }

    public static boolean isSOW(PSA_Project__c proj){
        Practice_Contribution__c oc = projectOfferingMap.get(proj.Id);
        if(oc?.Offering__c == MethodologyConstants.OFFERING_CUSTOM_SERVICES){
            return true;
        }else{
            Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
            DHQ_Product_Offering_Contribution__c dpoc = offeringDPOCMap.get(oc?.Offering__c);

            if(dpoc != null){
                if(dpoc.Product_Offering__r.Name == MethodologyConstants.OFFERING_SOW_PROJECT){
                    return true;
                }
            }
        }

        return false;
    }

    public static EDHQ_BT_BaseOfferingHandler getProcessingHandler(PSA_Project__c proj){
        EDHQ_BT_BaseOfferingHandler handler = new EDHQ_BT_BaseOfferingHandler();

        Practice_Contribution__c oc = projectOfferingMap.get(proj.Id);
         if(oc != null && oc.Offering__c == MethodologyConstants.OFFERING_CUSTOM_SERVICES){
            handler = new EDHQ_BT_CustomerServicesOfferingHandler();
         }
         else if(oc != null){
            Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
            DHQ_Product_Offering_Contribution__c dpoc = offeringDPOCMap.get(oc.Offering__c);

            if(dpoc != null){
                if(dpoc.Product_Offering__r.Name == MethodologyConstants.OFFERING_SOW_PROJECT){
                    handler = new EDHQ_BT_ExpertServicesOfferingHandler();
                }
            }
         }

         return handler;
    }
    
}