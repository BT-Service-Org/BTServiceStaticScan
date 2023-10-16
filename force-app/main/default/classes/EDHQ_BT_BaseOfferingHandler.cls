public virtual class EDHQ_BT_BaseOfferingHandler {
    
    
    public virtual void processOffering(PSA_Project__c proj){

        Map<String, DHQ_Product_Offering_Contribution__c> offeringDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_DPOC_MAP);
        Map<String, DHQ_Product_Offering_Contribution__c> workUnitDPOCMap = (Map<String, DHQ_Product_Offering_Contribution__c>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_WORK_UNIT_DPOC_MAP);
        DHQ_Product_Offering_Contribution__c dpoc = offeringDPOCMap.get(proj.Offering__c);
        
        if(dpoc != null && dpoc.Work_Unit_or_Offering__c == MethodologyConstants.OFFERING){

            createMFERecordsForDPOC(dpoc, proj);

            Map<String, Practice_Contribution__c> offeringContributionMap = (Map<String, Practice_Contribution__c>) EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_OFFERING_CONTRIBUTION_MAP);
            Practice_Contribution__c oc = offeringContributionMap.get(proj.Offering__c);

            if(proj.Offering__c == MethodologyConstants.OFFERING_PHASE_0_STRATEGIC_PLANNING && String.isNotBlank(oc.Work_Units__c)){
                
                List<String> workUnits = oc.Work_Units__c.split(';');

                for(String workUnit: workUnits){
                    createMFERecordsForDPOC(workUnitDPOCMap.get(workUnit), proj);
                }
                
            }

        }else{
            DHQ_Product_Offering_Contribution__c defaultDpoc = (DHQ_Product_Offering_Contribution__c)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_DEFAULT_DPOC);
            createMFERecordsForDPOC(defaultDpoc, proj);
        }
    }

    public void createMFERecordsForDPOC(DHQ_Product_Offering_Contribution__c dpoc, PSA_Project__c proj){
        if(dpoc != null){
            if(dpoc.Mapped_to__c == MethodologyConstants.PLAYBOOK){
                createMFERecordsForPlaybook(dpoc.Playbook__c, proj);
            }
            else if(dpoc.Mapped_to__c == MethodologyConstants.PLAYBOOK_STAGE){
                createMFERecordsForPlaybook(dpoc.Playbook__c, proj);
                if(dpoc.Playbook_Stage_Name__c != null && !dpoc.Playbook_Stage_Name__r.MandatoryStage__c){
                    createMFERecordsForStage(dpoc.Playbook_Stage_Name__c, proj);
                }
            }
        }
    }

    public void createMFERecordsForPlaybook(Id playbookId, PSA_Project__c proj){
        Map<Id, List<Stage__c>> playbookStageMap = (Map<Id, List<Stage__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_PLAYBOOK_STAGES_MAP);

        if(playbookId != null && playbookStageMap != null){
            List<Stage__c> stages = playbookStageMap.get(playbookId);
            
            if(stages != null){
                for(Stage__c stage: stages){
                    if(stage.MandatoryStage__c){
                        createMFERecordsForStage(stage.Id, proj);
                    }
                }
            }
        }
    }

    public void createMFERecordsForStage(Id stageId, PSA_Project__c proj){
        Map<Id, List<Method__c>> stageMethodsMap = (Map<Id, List<Method__c>>)EDHQ_BT_ApplicationContext.getContextValue(MethodologyConstants.KEY_STAGE_METHODS_MAP);
        if(String.isNotBlank(stageId) && stageMethodsMap !=null){
            List<Method__c> methodList = stageMethodsMap.get(stageId);

            if(methodList != null){
                ProjectMethodCalculationsBatchHelper.createMFERecords(methodList, proj);
            }
        }
    }

}