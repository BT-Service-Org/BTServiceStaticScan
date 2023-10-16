public without sharing class PlaybookController{
    @AuraEnabled
    public static string getPlaybookDetails(String playbookId){
        try{

            // Fetch Stages
            Map<Id, Stage__c> stageList = new Map<Id, Stage__c>([SELECT Id, Activities__c, Description__c, Key_Questions__c, Name, StageDuration__c, MandatoryStage__c, Objective__c, StageNumber__c, Playbook_Stage__c
                                                                 FROM Stage__c
                                                                 WHERE Playbook_Stage__c = :playbookId]);


            // Fetch Stage Outcomes
            List<Stage_Outcome__c> stageOutcomeList = [SELECT Id, Stage__c, Outcome__c,Order__c, Outcome__r.Name
                                                       FROM Stage_Outcome__c
                                                       WHERE Stage__c IN:stageList.keySet()];

            Map<Id, List<Stage_Outcome__c>> stageIdVsStageOutcome = new Map<Id, List<Stage_Outcome__c>>();
            Map<Id, List<Id>> stageIdVsOutcomeIds = new Map<Id, List<Id>>();
            List<Id> outcomeIds = new List<Id>();
            List<Id> stageOutcomeIds = new List<Id>();

            // Map Stage and Outcomes
            if (stageOutcomeList != null){
                for (Stage_Outcome__c eachStageOutcome : stageOutcomeList){
                    if (stageIdVsStageOutcome.get(eachStageOutcome.Stage__c) == null){
                        stageIdVsStageOutcome.put(eachStageOutcome.Stage__c, new List<Stage_Outcome__c>());
                        stageIdVsOutcomeIds.put(eachStageOutcome.Stage__c, new List<Id>());
                    }
                    stageIdVsStageOutcome.get(eachStageOutcome.Stage__c).add(eachStageOutcome);
                    stageIdVsOutcomeIds.get(eachStageOutcome.Stage__c).add(eachStageOutcome.Outcome__c);
                    outcomeIds.add(eachStageOutcome.Outcome__c);
                    stageOutcomeIds.add(eachStageOutcome.Id);
                }
            }

            //Fetch Stage Method Outcomes
            
            List<Stage_Method_Outcome__c> stageMethodOutcomeList = [SELECT id,Method_Outcome__c,Method_Outcome__r.Method__c,Method_Outcome__r.Method__r.Name,Method_Outcome__r.Outcome__c,Method_Outcome__r.Outcome__r.Name,Stage_Outcome__c,Order__c
                                                                  FROM Stage_Method_Outcome__c
                                                                  WHERE Stage_Outcome__c IN:stageOutcomeIds];

            Map<Id, List<Stage_Method_Outcome__c>> stageOutcomeIdVsStageMethodOutcome = new Map<Id, List<Stage_Method_Outcome__c>>();
            
            // Map Outcome with Stage Method Outcome
            if(stageMethodOutcomeList!=null)
            {
                for(Stage_Method_Outcome__c rec : stageMethodOutcomeList)
                {
                    if (stageOutcomeIdVsStageMethodOutcome.get(rec.Stage_Outcome__c) == null){
                        stageOutcomeIdVsStageMethodOutcome.put(rec.Stage_Outcome__c,new List<Stage_Method_Outcome__c>());
                    }
                    stageOutcomeIdVsStageMethodOutcome.get(rec.Stage_Outcome__c).add(rec);
                }
            }
            
            // Generate Wrapper
            PlaybookWrapper wrapper = new PlaybookWrapper();
            wrapper.playbookId = playbookId;
            wrapper.stages = new List<PlaybookWrapper.Stage>();
            for (Stage__c eachStage : stageList.values()){
                // Generate Stage wrapper
                wrapper.stages.add(generateStages(eachStage, stageIdVsStageOutcome, stageOutcomeIdVsStageMethodOutcome));
            }

            return JSON.serialize(wrapper);
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStacktraceString());
        }
    }

    // Need to change everything in outcomeIdVsMethods------
    public static PlaybookWrapper.Stage generateStages(Stage__c stage, Map<Id, List<Stage_Outcome__c>> stageIdVsStageOutcome, Map<Id, List<Stage_Method_Outcome__c>> stageOutcomeIdVsStageMethodOutcome){
        PlaybookWrapper.Stage stageObj = new PlaybookWrapper.Stage();
        stageObj.Activities = stage.Activities__c;
        stageObj.Description = stage.Description__c;
        stageObj.KeyQuestions = stage.Key_Questions__c;
        stageObj.StageTitle = stage.Name;
        stageObj.Duration = stage.StageDuration__c;
        stageObj.MandatoryStage = stage.MandatoryStage__c;
        stageObj.Objectives = stage.Objective__c;
        stageObj.recordId = stage.Id;
        stageObj.StageNumber = stage.StageNumber__c;

        stageObj.outcomeVsStageMethodOutcomeIds= new List<PlaybookWrapper.OutcomeVsStageMethodOutcomeIds>();
        if (stageIdVsStageOutcome.get(stage.Id) != null){
            for (Stage_Outcome__c eachStageOutcome : stageIdVsStageOutcome.get(stage.Id)){
                // Generate and add StageOutcome Wrapper
                stageObj.outcomeVsStageMethodOutcomeIds.add(generateOutcomes(eachStageOutcome.Outcome__c, eachStageOutcome.Outcome__r.Name,eachStageOutcome.Order__c, stageOutcomeIdVsStageMethodOutcome, eachStageOutcome.Id));
            }
        }

        return stageObj;
    }

    public static PlaybookWrapper.outcomeVsStageMethodOutcomeIds generateOutcomes(Id outcomeId, String outcomeName, Decimal outcomeOrder, Map<Id, List<Stage_Method_Outcome__c>> stageOutcomeIdVsStageMethodOutcome, Id stageOutcomeId){
        PlaybookWrapper.OutcomeVsStageMethodOutcomeIds outcomeObj = new PlaybookWrapper.OutcomeVsStageMethodOutcomeIds();
        outcomeObj.outcomeId = outcomeId;
        outcomeObj.outcomeName = outcomeName;
        outcomeObj.stageOutcomeId = stageOutcomeId;
        outcomeObj.outcomeOrder = String.valueOf(outcomeOrder);

        outcomeObj.stageMethodOutcomes = new List<PlaybookWrapper.StageMethodOutcome>();
        if (stageOutcomeIdVsStageMethodOutcome.get(stageOutcomeId) != null){
            for (Stage_Method_Outcome__c eachStageMethodOutcome : stageOutcomeIdVsStageMethodOutcome.get(stageOutcomeId)){
                // Generate and add methodOutcome wrapper
                outcomeObj.stageMethodOutcomes.add(generateStageMethodOutcome(eachStageMethodOutcome));
            }
        }

        return outcomeObj;
    }

    public static PlaybookWrapper.StageMethodOutcome generateStageMethodOutcome(Stage_Method_Outcome__c stageMethodOutcome){
        PlaybookWrapper.StageMethodOutcome stageMethodObj = new PlaybookWrapper.StageMethodOutcome();
        stageMethodObj.orderNumber = stageMethodOutcome.Order__c;
        stageMethodObj.methodId = stageMethodOutcome.Method_Outcome__r.Method__c;
        stageMethodObj.methodName = stageMethodOutcome.Method_Outcome__r.Method__r.Name;
        stageMethodObj.outcomeId = stageMethodOutcome.Method_Outcome__r.Outcome__c;
        stageMethodObj.outcomeName = stageMethodOutcome.Method_Outcome__r.Outcome__r.Name;
        stageMethodObj.stageMethodOutcomeId = stageMethodOutcome.Id;
        stageMethodObj.methodOutcomeId = stageMethodOutcome.Method_Outcome__c;
        stageMethodObj.stageOutcomeId = stageMethodOutcome.Stage_Outcome__c;
        return stageMethodObj;
    }

    @AuraEnabled
    public static String savePlaybookDetails(String wrapperString){
        try{
            PlaybookWrapper data = PlaybookWrapper.parse(wrapperString);
            List<Playbook__c> pb;
            // Get exsisting Playbook if any
            if (data.playbookId != null){
                pb = [SELECT Id, Status__c
                      FROM Playbook__c
                      WHERE Id = :data.playbookId];
            }

            Playbook__c plbk = new Playbook__c();
            plbk.Id = data.playbookId;
            plbk.Name = data.playbookName;
            plbk.Description__c = data.playbookDescription;
            plbk.Contract_Type__c = data.playbookContractType;

            List<String> editableStages = new List<String>{ 'Draft', 'Ready for Review', 'Initial Methodology Team Review', 'Need Amendments', 'Live' };
            if (pb != null && pb[0].Status__c != null && pb[0].Status__c == 'Live'){
                return createDraftPlayBook(wrapperString);
            } else{

                // Update to draft only if Status is Pending
                if (pb != null && pb[0].Status__c != null && !editableStages.contains(pb[0].Status__c)){
                    throw new CalloutException('Cannot edit playbook which is in status ' + pb[0].Status__c);
                } else if (pb != null && pb[0].Status__c != null){
                    plbk.Status__c = pb[0].Status__c;
                } else{
                    plbk.Status__c = 'Draft';
                }
                // Upsert playbook record
                upsert plbk;

                List<Stage__c> stagesToUpsert = new List<Stage__c>();
                Integer index = 0;
                Map<Integer, Stage__c> indexVsStage = new Map<Integer, Stage__c>();

                // Generate and add Stage record with respective index
                for (PlaybookWrapper.Stage eachStage : data.stages){
                    indexVsStage.put(index, generateStagesRecord(eachStage, plbk.Id));
                    index++;
                }

                // Upsert the stages
                upsert indexVsStage.values();

                index = 0;
                Map<Integer, PlaybookWrapper.Stage> indexVsStageObj = new Map<Integer, PlaybookWrapper.Stage>();
                List<String> outcomeIds = new List<String>();
                List<String> methodIds = new List<String>();
                List<String> stageIds = new List<String>();

                // Map upserted stages with index and collect outcome/method ids
                for (Integer eachIndex : indexVsStage.keySet()){
                    data.stages[eachIndex].recordId = indexVsStage.get(eachIndex).Id;
                    stageIds.add(indexVsStage.get(eachIndex).Id);
                    indexVsStageObj.put(eachIndex, data.stages[eachIndex]);
                    if (data.stages[eachIndex]?.outcomeVsStageMethodOutcomeIds != null){
                        for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachoutcome : data.stages[eachIndex].outcomeVsStageMethodOutcomeIds){
                            outcomeIds.add(eachoutcome.outcomeId);
                            if(eachoutcome.stageMethodOutcomes!=null)
                            {
                                for (PlaybookWrapper.StageMethodOutcome eachStageMethodOutcome : eachoutcome.stageMethodOutcomes){
                                    //we might need more here
                                    methodIds.add(eachStageMethodOutcome.methodId);
                                }
                            }
                        }
                    }

                    index++;
                }

                // Fetch any exsting Stage by Playbook, Stage Outcome by Stage and Method Outcome by Outcome

                List<Stage__c> existingStageDb = [SELECT Id
                                                  FROM Stage__c
                                                  WHERE Playbook_Stage__c = :plbk.Id];
                List<Stage_Outcome__c> existingStageOutcomesDb = [SELECT Id, Stage__c, Outcome__c,Order__c
                                                                  FROM Stage_Outcome__c
                                                                  WHERE Stage__c IN:stageIds];

                List<Id> listExistingStageOutcomeIdsInDB = new List<Id>();
                for(Stage_Outcome__c stageOutcomeRec : existingStageOutcomesDb)
                {
                    listExistingStageOutcomeIdsInDB.add(stageOutcomeRec.Id);
                }

                List<Stage_Method_Outcome__c> existingStageMethodOutcomeDb = [SELECT id,Method_Outcome__r.Method__c,Method_Outcome__r.Method__r.Name,Method_Outcome__r.Outcome__c,Method_Outcome__r.Outcome__r.Name,Stage_Outcome__c,Stage_Outcome__r.Outcome__c,Order__c
                                                                    FROM Stage_Method_Outcome__c
                                                                    WHERE Stage_Outcome__c IN:listExistingStageOutcomeIdsInDB];

                Map<Id, List<Stage_Outcome__c>> existingStageVsOutcomes = new Map<Id, List<Stage_Outcome__c>>();
                Map<Id, List<Stage_Method_Outcome__c>> existingStageOutcomeVsStageMethodOutcome = new Map<Id, List<Stage_Method_Outcome__c>>();

                // Map existing Outcomes with Stage
                for (Stage_Outcome__c eachStageOutcome : existingStageOutcomesDb){
                    if (existingStageVsOutcomes.get(eachStageOutcome.Stage__c) == null){
                        existingStageVsOutcomes.put(eachStageOutcome.Stage__c, new List<Stage_Outcome__c>());
                    }

                    existingStageVsOutcomes.get(eachStageOutcome.Stage__c).add(eachStageOutcome);
                }

                // Map existing Stage Outcome with Stage Method Outcome
                for (Stage_Method_Outcome__c eachStageMethodOutcome : existingStageMethodOutcomeDb){
                    if (existingStageOutcomeVsStageMethodOutcome.get(eachStageMethodOutcome.Stage_Outcome__c) == null){
                        existingStageOutcomeVsStageMethodOutcome.put(eachStageMethodOutcome.Stage_Outcome__c, new List<Stage_Method_Outcome__c>());
                    }
                    existingStageOutcomeVsStageMethodOutcome.get(eachStageMethodOutcome.Stage_Outcome__c).add(eachStageMethodOutcome);
                }

                // Fetch existing Stage Outcome using Stage Ids and Outcome Ids of UI
                Map<Id, Stage_Outcome__c> stageOutcomesDb = new Map<Id, Stage_Outcome__c>([SELECT Id, Stage__c, Outcome__c
                                                                                           FROM Stage_Outcome__c
                                                                                           WHERE Stage__c IN:stageIds AND Outcome__c IN:outcomeIds]);

                // Fetch existing Method Outcome using Outcome Ids and Method Ids of UI
                Map<Id, Stage_Method_Outcome__c> stageMethodsOutcomeDb = new Map<Id, Stage_Method_Outcome__c>([SELECT id,Method_Outcome__r.Method__c,Method_Outcome__r.Method__r.Name,Method_Outcome__r.Outcome__c,Method_Outcome__r.Outcome__r.Name,Stage_Outcome__c,Stage_Outcome__r.Outcome__c,Order__c
                                                                                                FROM Stage_Method_Outcome__c
                                                                                                WHERE Stage_Outcome__c IN:stageOutcomesDb.keySet() AND Method_Outcome__r.Method__c IN:methodIds]);


                Map<Id, List<Id>> stageIdVsOutcomeIds = new Map<Id, List<Id>>();
                Map<Id, List<Stage_Method_Outcome__c>> outcomeIdVsStageMethodOutcomes = new Map<Id, List<Stage_Method_Outcome__c>>();


                // Map existing Stage and Outcome got from existing Stage Outcome using UI stage and outcome ids
                for (Stage_Outcome__c eachStageOutcome : stageOutcomesDb.values()){
                    if (stageIdVsOutcomeIds.get(eachStageOutcome.Stage__c) == null){
                        stageIdVsOutcomeIds.put(eachStageOutcome.Stage__c, new List<String>());
                    }

                    stageIdVsOutcomeIds.get(eachStageOutcome.Stage__c).add(eachStageOutcome.Outcome__c);
                }

                // Map existing Method and Outcome got from existing Method Outcome using UI method and outcome ids
                for (Stage_Method_Outcome__c eachStageMethodOutcome : stageMethodsOutcomeDb.values()){
                    if (outcomeIdVsStageMethodOutcomes.get(eachStageMethodOutcome.Stage_Outcome__r.Outcome__c) == null){
                        outcomeIdVsStageMethodOutcomes.put(eachStageMethodOutcome.Stage_Outcome__r.Outcome__c, new List<Stage_Method_Outcome__c>());
                    }

                    outcomeIdVsStageMethodOutcomes.get(eachStageMethodOutcome.Stage_Outcome__r.Outcome__c).add(eachStageMethodOutcome);
                }


                List<Stage_Outcome__c> stageOutcomeToUpsert = new List<Stage_Outcome__c>();
                List<Stage_Method_Outcome__c> stageMethodOutcomeToUpsert = new List<Stage_Method_Outcome__c>();

                List<Stage_Outcome__c> stageOutcomesToDelete = new List<Stage_Outcome__c>();
                Set<Stage_Method_Outcome__c> stageMethodOutcomeToDelete = new Set<Stage_Method_Outcome__c>();

                // Check and collect deleted Stages on UI, for deletion of Stages which are not on UI but in DB
                List<Stage__c> stageToDelete = checkExistingStage(existingStageDb, data.stages);

                for (PlaybookWrapper.Stage eachStageObj : data.stages){
                    // Check and collect deleted Stage Outcome on UI, for deletion of Stage Outcome which are not on UI but in DB
                    List<Stage_Outcome__c> soList = checkForExistingStageVsOutcome(existingStageVsOutcomes.get(eachStageObj.recordId), eachStageObj.outcomeVsStageMethodOutcomeIds);
                    if (!soList.isEmpty()){
                        stageOutcomesToDelete.addAll(soList);
                    }

                    if (eachStageObj?.outcomeVsStageMethodOutcomeIds != null){
                        for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachOutcomeObj : eachStageObj.outcomeVsStageMethodOutcomeIds){
                            // Generate Stage Outcome Records to be upserted
                            stageOutcomeToUpsert.add(generateStageOutcomeRec(eachOutcomeObj.stageOutcomeId,eachStageObj.recordId, eachOutcomeObj.outcomeId, eachOutcomeObj.outcomeOrder));
                        }
                    }
                }


                // delete existing Stage, Stage Outcome and Method Outcome
                if (!stageToDelete.isEmpty()){
                    delete stageToDelete;
                }
                // insert/update Stage Outcome and Method Outcome
                if (!stageOutcomeToUpsert.isEmpty()){
                    upsert stageOutcomeToUpsert;
                }
                if (!stageOutcomesToDelete.isEmpty()){
                    delete stageOutcomesToDelete;
                }

                //Used to fetch stage outcomes that were also inserted
                List<Stage_Outcome__c> listSo = new List<Stage_Outcome__c>([SELECT Id, Stage__c, Outcome__c,Order__c
                                                                            FROM Stage_Outcome__c
                                                                            WHERE Stage__c IN :stageIds]);
                Map<String, Id> outcomeToStageOutcomeMap = new Map<String, Id>();
                for(Stage_Outcome__c soRec: listSo)
                {
                    String stageOutcome = createStageOutcome(soRec.Outcome__c,String.valueOf(soRec.Order__c),soRec.Stage__c);
                    outcomeToStageOutcomeMap.put(stageOutcome,soRec.Id);
                }
                
                //Generate Stage Method Outcomes to upsert
                for (PlaybookWrapper.Stage eachStageObj : data.stages){
                    if (eachStageObj?.outcomeVsStageMethodOutcomeIds != null){
                        for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachOutcomeObj : eachStageObj.outcomeVsStageMethodOutcomeIds){               
                            //All stage method outcomes to delete
                            List<Stage_Method_Outcome__c> smoList = checkForExistingOutcomeVsStageMethodOutcome(existingStageOutcomeVsStageMethodOutcome.get(eachOutcomeObj.stageOutcomeId), eachOutcomeObj.stageMethodOutcomes);
                            if (!smoList.isEmpty()){
                                stageMethodOutcomeToDelete.addAll(smoList);
                            }                

                            // Generate/Update Method Outcome Records to be upserted
                            ///partially changed
                            if(eachOutcomeObj.stageMethodOutcomes!=null)
                            {
                                for(PlaybookWrapper.StageMethodOutcome eachStageMethodOutcome : eachOutcomeObj.stageMethodOutcomes){
                                    Stage_Method_Outcome__c smoRec = generateStageMethodOutcomeForCreation(eachOutcomeObj.outcomeId, eachStageMethodOutcome,outcomeToStageOutcomeMap,eachOutcomeObj.outcomeOrder,eachStageObj.recordId,'Upsert');
                                    stageMethodOutcomeToUpsert.add(smoRec);
                                }
                            }

                        }
                    }
                }

                
                //Deleting stage method outcomes that were removed
                if (!stageMethodOutcomeToDelete.isEmpty()){
                    if (stageMethodOutcomeToUpsert.size() > 0){
                        Set<Stage_Method_Outcome__c> upsertSet = new Set<Stage_Method_Outcome__c>(stageMethodOutcomeToUpsert);

                        for (Stage_Method_Outcome__c stageMethodOutcome : stageMethodOutcomeToUpsert){
                            if (upsertSet.contains(stageMethodOutcome)){
                                stageMethodOutcomeToDelete.remove(stageMethodOutcome);
                            }
                        }
                    }
                    if (stageMethodOutcomeToDelete.size() > 0){
                        delete new List<Stage_Method_Outcome__c>(stageMethodOutcomeToDelete);
                    }
                }

                //Upserting stage method outcomes
                if (!stageMethodOutcomeToUpsert.isEmpty()){
                    Database.upsert(stageMethodOutcomeToUpsert, Stage_Method_Outcome__c.Fields.Id, true) ;
                }

                return plbk.Id;
            }
        } catch (CalloutException ce){
            throw new AuraHandledException(ce.getMessage());
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStacktraceString());
        }
    }

    public static List<Stage__c> checkExistingStage(List<Stage__c> existingStageDb, List<PlaybookWrapper.Stage> stages){
        List<Stage__c> stagesToDelete = new List<Stage__c>();
        if (existingStageDb != null){
            for (Stage__c eachStageDb : existingStageDb){
                Boolean found = false;
                for (PlaybookWrapper.Stage eachStageObj : stages){
                    if (eachStageDb.Id == eachStageObj.recordId){
                        found = true;
                        break;
                    }
                }
                if (!found){
                    stagesToDelete.add(eachStageDb);
                }
            }
        }
        return stagesToDelete;
    }

    public static List<Stage_Outcome__c> checkForExistingStageVsOutcome(List<Stage_Outcome__c> existingStageVsOutcomes, List<PlaybookWrapper.OutcomeVsStageMethodOutcomeIds> outcomeVsStageMethodOutcomeIds){
        List<Stage_Outcome__c> stageOutcomesToDelete = new List<Stage_Outcome__c>();

        if (existingStageVsOutcomes != null){
            for (Stage_Outcome__c eachStageOutcome : existingStageVsOutcomes){
                Boolean found = false;
                for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachStageOutcomeObj : outcomeVsStageMethodOutcomeIds){
                    if (eachStageOutcomeObj.stageOutcomeId == eachStageOutcome.Id){
                        found = true;
                        break;
                    }
                }
                if (!found){
                    stageOutcomesToDelete.add(eachStageOutcome);
                }
            }
        }

        return stageOutcomesToDelete;
    }

    public static List<Stage_Method_Outcome__c> checkForExistingOutcomeVsStageMethodOutcome(List<Stage_Method_Outcome__c> existingStageMethodOutcome, List<PlaybookWrapper.StageMethodOutcome> stageMethodOutcome){
        List<Stage_Method_Outcome__c> stageMethodOutcomesToDelete = new List<Stage_Method_Outcome__c>();
        if (existingStageMethodOutcome != null){
            for (Stage_Method_Outcome__c eachStageOutcomeMethod : existingStageMethodOutcome){
                Boolean found = false;
                for (PlaybookWrapper.StageMethodOutcome eachStageMethodOutcome : stageMethodOutcome){
                    if (eachStageMethodOutcome.stageMethodOutcomeId == eachStageOutcomeMethod.Id){
                        found = true;
                        break;
                    }
                }
                if (!found){
                    stageMethodOutcomesToDelete.add(eachStageOutcomeMethod);
                }
            }
        }
        return stageMethodOutcomesToDelete;
    }

    public static Stage__c generateStagesRecord(PlaybookWrapper.Stage stageObj, String playbookId){
        Stage__c stageRec = new Stage__c();
        stageRec.Activities__c = stageObj.Activities;
        stageRec.Description__c = stageObj.Description;
        stageRec.Key_Questions__c = stageObj.KeyQuestions;
        stageRec.Name = stageObj.StageTitle;
        stageRec.StageDuration__c = stageObj.Duration;
        stageRec.MandatoryStage__c = stageObj.MandatoryStage;
        stageRec.Objective__c = stageObj.Objectives;
        stageRec.Id = stageObj.recordId;
        stageRec.StageNumber__c = stageObj.StageNumber;
        stageRec.Playbook_Stage__c = playbookId;
        return stageRec;
    }

    public static Stage_Outcome__c generateStageOutcomeRec(String stageOutcomeId,String stageId, String outcomeId, String outcomeOrder){
        Stage_Outcome__c stageOutcomeRec = new Stage_Outcome__c();
        if(stageOutcomeId!=null)
        {
            stageOutcomeRec.Id=stageOutcomeId;
        }
        stageOutcomeRec.Stage__c = stageId;
        stageOutcomeRec.Outcome__c = outcomeId;
        if(outcomeOrder!=null)
        {
            stageOutcomeRec.Order__c = Decimal.valueOf(outcomeOrder);
        }
        return stageOutcomeRec;
    }

    public static Stage_Method_Outcome__c generateStageMethodOutcomeForCreation(String outcomeId, PlaybookWrapper.StageMethodOutcome stageMethodOutcomeObj,Map<String, Id> outcomeToStageOutcomeMap,String outcomeOrder,String stageId, String action){
        
        Stage_Method_Outcome__c smoRec = new Stage_Method_Outcome__c();
        //used to store string value of PlaybookWrapper.StageOutcome
        String stageOutcome = createStageOutcome(outcomeId,outcomeOrder,stageId);
        if(action != 'Insert')
        {
            smoRec.Id = stageMethodOutcomeObj.stageMethodOutcomeId;
        }
        smoRec.Order__c = stageMethodOutcomeObj.orderNumber;
        smoRec.Stage_Outcome__c = outcomeToStageOutcomeMap.get(stageOutcome);
        smoRec.Method_Outcome__c = stageMethodOutcomeObj.methodOutcomeId;     
        return smoRec;
    }

    public static Stage_Method_Outcome__c checkForMethodsInOutcome(PlaybookWrapper.OutcomeVsStageMethodOutcomeIds outcomeObj, PlaybookWrapper.StageMethodOutcome stageMethodOutcomeObj, Map<Id, List<Stage_Method_Outcome__c>> outcomeIdVsStageMethodOutcomes){
        Stage_Method_Outcome__c result = null;

        if (outcomeIdVsStageMethodOutcomes.get(outcomeObj.outcomeId) != null){
            for (Stage_Method_Outcome__c eachMethod : outcomeIdVsStageMethodOutcomes.get(outcomeObj.outcomeId)){
                if (stageMethodOutcomeObj.stageMethodOutcomeId == eachMethod.Id){
                    result = eachMethod;
                    break;
                }
            }
        }

        return result;
    }

    public static String createDraftPlayBook(String wrapperString){
        PlaybookWrapper data = PlaybookWrapper.parse(wrapperString);
        Playbook__c playbookRec = [Select Id, Name, Contract_Type__c, CurrencyIsoCode, Description__c, Order__c, Playbook__c, SME__c, SME_Lookup__c, Specialist_Cloud__c, Status__c
                                   from Playbook__c
                                   where Id = :data.playbookId];
        Playbook__c plbk = new Playbook__c();
        plbk.Name = data.playbookName;
        plbk.Description__c = data.playbookDescription;
        plbk.Contract_Type__c = data.playbookContractType;
        if (playbookRec.CurrencyIsoCode != null)
            plbk.CurrencyIsoCode = playbookRec.CurrencyIsoCode;
        if (playbookRec.Order__c != null)
            plbk.Order__c = playbookRec.Order__c;
        if (playbookRec.SME__c != null)
            plbk.SME__c = playbookRec.SME__c;
        if (playbookRec.SME_Lookup__c != null)
            plbk.SME_Lookup__c = playbookRec.SME_Lookup__c;
        if (playbookRec.Specialist_Cloud__c != null)
            plbk.Specialist_Cloud__c = playbookRec.Specialist_Cloud__c;
        plbk.Playbook__c = data.playbookId;
        plbk.Status__c = 'Draft';
        insert plbk;

        Integer index = 0;
        Map<Integer, Stage__c> indexVsStage = new Map<Integer, Stage__c>();
        for (PlaybookWrapper.Stage eachStage : data.stages){
            Stage__c stageRec = new Stage__c();
            stageRec.Activities__c = eachStage.Activities;
            stageRec.Description__c = eachStage.Description;
            stageRec.Key_Questions__c = eachStage.KeyQuestions;
            stageRec.Name = eachStage.StageTitle;
            stageRec.StageDuration__c = eachStage.Duration;
            stageRec.MandatoryStage__c = eachStage.MandatoryStage;
            stageRec.Objective__c = eachStage.Objectives;
            stageRec.StageNumber__c = eachStage.StageNumber;
            stageRec.Playbook_Stage__c = plbk.Id;
            indexVsStage.put(index, stageRec);
            index++;
        }
        insert indexVsStage.values();

        //no use code
        Index = 0;
        Map<Integer, PlaybookWrapper.Stage> indexVsStageObj = new Map<Integer, PlaybookWrapper.Stage>();
        List<String> outcomeIds = new List<String>();
        List<String> stageMethodOutcomeIds = new List<String>();
        List<String> methodIds = new List<String>();
        List<String> stageIds = new List<String>();

        for (Integer eachIndex : indexVsStage.keySet()){
            data.stages[eachIndex].recordId = indexVsStage.get(eachIndex).Id;
            stageIds.add(indexVsStage.get(eachIndex).Id);
            indexVsStageObj.put(eachIndex, data.stages[eachIndex]);
            if (data.stages[eachIndex]?.outcomeVsStageMethodOutcomeIds != null){
                for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachOutcome : data.stages[eachIndex].outcomeVsStageMethodOutcomeIds){
                    outcomeIds.add(eachOutcome.outcomeId);
                    if(eachOutcome.stageMethodOutcomes!=null)
                    {
                        for (PlaybookWrapper.StageMethodOutcome eachStageMethodOutcome : eachOutcome.stageMethodOutcomes){
                            methodIds.add(eachStageMethodOutcome.methodId);
                        }
                    }
                }
            }
            index++;
        }

        List<Stage_Outcome__c> stageOutcomeToInsert = new List<Stage_Outcome__c>();
        List<Stage_Method_Outcome__c> stageMethodOutcomeToInsert = new List<Stage_Method_Outcome__c>();

        for (PlaybookWrapper.Stage eachStageObj : data.stages){
            if (eachStageObj?.outcomeVsStageMethodOutcomeIds != null){
                for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachOutcomeObj : eachStageObj.outcomeVsStageMethodOutcomeIds){
                    stageOutcomeToInsert.add(generateStageOutcomeRec(null,eachStageObj.recordId, eachOutcomeObj.outcomeId, eachOutcomeObj.outcomeOrder));
                }
            }
        }
        if (!stageOutcomeToInsert.isEmpty()){
            insert stageOutcomeToInsert;
        }                   
        
        //Used to fetch stage outcomes that were also inserted
        List<Stage_Outcome__c> listSo = new List<Stage_Outcome__c>([SELECT Id, Stage__c, Outcome__c,Order__c
                                                                    FROM Stage_Outcome__c
                                                                    WHERE Stage__c IN:stageIds]);
        Map<String, Id> outcomeToStageOutcomeMap = new Map<String, Id>();
        for(Stage_Outcome__c soRec: listSo)
        {
            String stageOutcome = createStageOutcome(soRec.Outcome__c,String.valueOf(soRec.Order__c),soRec.Stage__c);
            outcomeToStageOutcomeMap.put(stageOutcome,soRec.Id);
        }             

        //Form all stage method outcomes
        for (PlaybookWrapper.Stage eachStageObj : data.stages){
            if (eachStageObj?.outcomeVsStageMethodOutcomeIds != null){
                for (PlaybookWrapper.OutcomeVsStageMethodOutcomeIds eachOutcomeObj : eachStageObj.outcomeVsStageMethodOutcomeIds){
                    if(eachOutcomeObj.stageMethodOutcomes!=null){
                        for (PlaybookWrapper.StageMethodOutcome eachStageMethodOutcome : eachOutcomeObj.stageMethodOutcomes){
                            stageMethodOutcomeToInsert.add(generateStageMethodOutcomeForCreation(eachOutcomeObj.outcomeId, eachStageMethodOutcome,outcomeToStageOutcomeMap,eachOutcomeObj.outcomeOrder,eachStageObj.recordId,'Insert'));
                        }
                    }
                }
            }
        }
        
        if (!stageMethodOutcomeToInsert.isEmpty()){
            insert stageMethodOutcomeToInsert;
        }
        return plbk.Id;
    }
    
    @AuraEnabled
    public static void createOutcomeRecord(String name,String description,String title)
    {
        Outcome__c record= new Outcome__c();
        record.Name = name;
        record.Description__c = description;
        record.Title__c = title;
        record.recordtypeid = Schema.SObjectType.Outcome__c.getRecordTypeInfosByDeveloperName().get('Stage').getRecordTypeId();
        insert record;
    }

    @AuraEnabled
    public static sObject getMethodOutcomes(String recordId){
        string sQuery = 'Select Id,Name,(Select id,Outcome__c,Outcome__r.Name from Method_Outcomes__r) From method__c Where Id = : recordId LIMIT 1';
        for (sObject obj : database.query(sQuery)) {
            return obj;
        }
        return null;
    }

    public static string createStageOutcome(String outcomeId,String order,String stageId)
    {
        PlaybookWrapper.StageOutcome soRec = new PlaybookWrapper.StageOutcome();
        soRec.outcomeId = outcomeId;
        soRec.order = order;
        soRec.stageId = stageId;
        return String.valueOf(soRec);
    }

}