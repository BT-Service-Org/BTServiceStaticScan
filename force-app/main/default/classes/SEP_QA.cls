public class SEP_QA {
	
    //returns question and answers for given assessment ID
    @AuraEnabled (cacheable=true)
    public static List<SEP_QA2Capability__c> getSepQA_Details(ID assessid){
        
        System.debug('qa assessid is '+ assessid + ' ' + assessid.to15());
        //for the given capa2domain id we first need the full list of associated capas
        try {
            return [
                select ID, SEP_Capability_ID__c, SEP_Query__c,
                SEP_Answer_1__c, SEP_Answer_2__c, SEP_Answer_3__c, SEP_Answer_4__c, SEP_Answer_5__c ,Selected_Answer__c, Question_Note__c, 
                SEP_Question_Answer__c, Parent_Question__c, Dependent_Answer__c
                from SEP_QA2Capability__c 
                where SEP_Assessment_ID__c = :assessid.to15()
                ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<SEP_Capability2Domain__c> getCapaFP4Domain(ID assessid){
        try {
            return [
                select Id, SEP_Capability_Name__c, Function_Points_Sum__c, Total_of_Possible_Function_Points__c, Function_Point_Consumption__c from SEP_Capability2Domain__c where SEP_Domain2Assesment__c = :assessid.to15()
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<SEP_Domain2Assesment__c> getRelatedDomains4SameAssessment(ID domainid){
        System.debug('--> get related domains: domain id is '+ domainid + ' ' + domainid.to15());
        
        //for given record we need the umbrella assessment id first
        SEP_Domain2Assesment__c d2a = [
            SELECT id, Name, SEP_Stream_Assessment__c ,Total_of_Possible_Function_Points__c, Function_Point_Consumption__c from SEP_Domain2Assesment__c  WHERE Id = :domainid.to15()
        ];
        ID assessID = d2a.SEP_Stream_Assessment__c;
        System.debug('--> get related domains: assess id is '+ assessID + ' ' + assessID.to15());
        //get all domains for same assessment 
        List<SEP_Domain2Assesment__c> d2aList = [
            SELECT id, name ,Total_of_Possible_Function_Points__c, Function_Point_Consumption__c from SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__c = :assessID.to15() AND isActive__c = true
            ORDER BY name
        ];
        return d2aList;
        
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Integer> getCompletionProgressData(ID assessid) {
        try {
            List<SEP_QA2Capability__c> allQ = [
                SELECT ID FROM SEP_QA2Capability__c WHERE SEP_Assessment_ID__c = :assessid.to15()
            ];

            List<SEP_QA2Capability__c> answeredQ = [
                SELECT ID, Selected_Answer__c FROM SEP_QA2Capability__c WHERE SEP_Assessment_ID__c = :assessid.to15() AND Selected_Answer__c != null
            ];

            List<Integer> completionProgressData = new List<Integer>();
            completionProgressData.add(answeredQ.size());
            completionProgressData.add(allQ.size());

            return completionProgressData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled()
    public static void updateAssessment(ID assessid, List<SEP_QA2Capability__c> records) {
        System.debug('--> Update Assess: assessid is '+ assessid + ' ' + assessid.to15());
        if(records == null) {
            System.debug('QA2Capability list size is null');
            return;
        }
        //update all QA records with selected value
        try {
            update records;
            System.debug('updated QA2Capability records ' );
        } catch (DmlException e) {
            System.debug('Failed to update QA2Capability records, ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        Integer totalQACount = 0;
        Integer answeredQACount = 0;

        for(SEP_QA2Capability__c record : records) {
            System.debug('record : ' + record);
            totalQACount += 1;
            if(record.Selected_Answer__c != null) {
                answeredQACount += 1;
            }
        }

        System.debug('totalQACount : ' + totalQACount);
        System.debug('answeredQACount : ' + answeredQACount);
        
        Set<String> capabilityIds = new Set<String>();
        Set<Id> qaIds = new Set<Id>();
        List<SEP_Question_Answers__c> ansQAs = new List<SEP_Question_Answers__c>();
        List<SEP_QA2Capability__c> qa2Caps = new List<SEP_QA2Capability__c> ();
        Map<Id, Double> qa2MaxFps = new Map<Id, Double> ();
        Map<Id,Set<Id>> cap2allQAs = new Map<Id,Set<Id>> ();
        Map<Id, Double> cap2TotalMaxFps = new Map<Id, Double> ();

        // get all capa2domain records for this domain assessment
        List<SEP_Capability2Domain__c> c2dList = [select SEP_Capability_ID__c, SEP_Capability_Name__c,  Function_Points_Sum__c, Total_of_Possible_Function_Points__c from SEP_Capability2Domain__c where SEP_Domain2Assesment__c = :assessid.to15()];
        for (SEP_Capability2Domain__c c2d : c2dList) {
            System.debug('--> iterate over c2d '+ c2d.SEP_Capability_Name__c +' ' + c2d.Id + ' capa id ' + c2d.SEP_Capability_ID__c);
            List<AggregateResult> groupedResults = [Select sum(Function_Points__c) from SEP_QA2Capability__c 
                                                    where SEP_QA2Capability__c.SEP_Assessment_ID__c = :assessid.to15() and SEP_QA2Capability__c.SEP_Capability_ID__c = :c2d.SEP_Capability_ID__c];
            Decimal capaFP = (Decimal) groupedResults[0].get('expr0');
            System.debug('--> iterate over c2d, capa fp '+ capaFP);
            c2d.Function_Points_Sum__c = capaFP;
            System.debug('--> iterate over c2d, capa sum on record '+ c2d.Function_Points_Sum__c);
            if(c2d.SEP_Capability_ID__c!=null) {
                capabilityIds.add(c2d.SEP_Capability_ID__c);
            }
        }

        System.debug('*SM_ capabilityIds*'+capabilityIds);
        //SM
        qa2Caps = [Select id,SEP_Question_Answer__c,SEP_Capability_ID__c from SEP_QA2Capability__c where SEP_QA2Capability__c.SEP_Assessment_ID__c = :assessid.to15() and SEP_QA2Capability__c.SEP_Capability_ID__c IN :capabilityIds ];  //removed as we consider all questions and Selected_Answer__c!= null
        System.debug('*SM_ qa2Caps*'+qa2Caps);
        for(SEP_QA2Capability__c qa2Cap : qa2Caps) {
            if(qa2Cap.SEP_Question_Answer__c != null) {qaIds.add(qa2Cap.SEP_Question_Answer__c);}

            ID capRecId = qa2Cap.SEP_Capability_ID__c;
            if(cap2allQAs.containskey(capRecId)){
                cap2allQAs.get(capRecId).add(qa2Cap.SEP_Question_Answer__c);
                }
                else{
                set<id> capAaIDS = new set<id>();
                capAaIDS.add(qa2Cap.SEP_Question_Answer__c);
                cap2allQAs.put(capRecId, capAaIDS); //i.e.  {capability : all answered questions}
                }
        }
        System.debug('*SM_ qaIds*'+qaIds);
        System.debug('*SM_ cap2allQAs*'+cap2allQAs);
        if(!qaIds.isEmpty()) {
            //ansQAs = [Select Id, FP0__c, FP1__c, FP2__c, FP3__c, FP4__c, FP5__c from SEP_Question_Answers__c where id IN :qaIds];
            for(SEP_Question_Answers__c qaInfo : [Select Id, FP0__c, FP1__c, FP2__c, FP3__c, FP4__c, FP5__c from SEP_Question_Answers__c where id IN :qaIds]) {
                Double maxFp = Math.max(
                                    Math.max(
                                        Math.max( 
                                            Math.max(
                                                Math.max(qaInfo.FP0__c, (qaInfo.FP1__c==null ? 0 : qaInfo.FP1__c) ), 
                                            (qaInfo.FP2__c==null ? 0 : qaInfo.FP2__c) ),
                                        (qaInfo.FP3__c==null ? 0 : qaInfo.FP3__c) ),
                                    (qaInfo.FP4__c==null ? 0 : qaInfo.FP4__c) ),
                                (qaInfo.FP5__c==null ? 0 : qaInfo.FP5__c) );
                qa2MaxFps.put(qaInfo.Id, maxFp);
            }
            System.debug('*SM_ qa2MaxFps*'+qa2MaxFps);

            for (SEP_Capability2Domain__c c2d : c2dList) {
                Id capID = c2d.SEP_Capability_ID__c;
                Double totalMaxFps = 0;
            
                Set<Id> allQaIds = cap2allQAs.get(capID);
                System.debug('**SM_ capID**'+capID);
                System.debug('**SM_ qaIds*'+allQaIds);
                if(allQaIds == null) {
                    c2d.Total_of_Possible_Function_Points__c = 0; //no answered questions found for the capability !
                }else{
                    for(ID qaId: allQaIds) {
                        if(qa2MaxFps.get(qaId) != null) {totalMaxFps += qa2MaxFps.get(qaId);}
                    }
                    c2d.Total_of_Possible_Function_Points__c = totalMaxFps;
                }
                
                System.debug('*SM_ capID | totalMaxFps*'+capID+'|'+totalMaxFps);
                
            }
            
        }
        

        System.debug('--> Updated list = ' + c2dList);
        update c2dList;
        
        //get the total Function Point call for the current assessment
        List<AggregateResult> groupedResults = [Select sum(Function_Points__c) from SEP_QA2Capability__c where SEP_Assessment_ID__c = :assessid.to15()];
        Decimal totalFP = (Decimal) groupedResults[0].get('expr0');
        System.debug('--> Update Assess: total FP = ' + totalFP + 'list size ' + groupedResults.size() + '>>> ' + groupedResults);
        
        //update domain2assessment object
        SEP_Domain2Assesment__c d2a = new SEP_Domain2Assesment__c();
        d2a = [select Id, Function_Points_Sum__c, Completion_Progress__c, SEP_Stream_Assessment__c,Total_of_Possible_Function_Points__c, Function_Point_Consumption__c from SEP_Domain2Assesment__c  where Id = :assessid.to15() ];
        d2a.Function_Points_Sum__c = totalFP;
        
        
        //update Total # of Possible Function Points on domain2assessment object
        List<AggregateResult> groupedRC2DResults = [Select sum(Total_of_Possible_Function_Points__c) from SEP_Capability2Domain__c where SEP_Domain2Assesment__c =:assessid.to15()];
        Decimal totalPFP = (Decimal) groupedRC2DResults[0].get('expr0');
        d2a.Total_of_Possible_Function_Points__c = totalPFP;
        
       
        
        if (totalQACount > 0) {
            Decimal percentage = (Decimal.valueOf(answeredQACount) / totalQACount) * 100;
            d2a.Completion_Progress__c = percentage.round(System.RoundingMode.HALF_UP);
        } else {
            d2a.Completion_Progress__c = 0;
        }
        update d2a;
        
        //update Stream Object
        
        //get ID of umbrella stream record
        ID streamID = d2a.SEP_Stream_Assessment__c;
        System.debug('--> Update stream object for ID = ' + streamID);
        //get the total Function Point call for the stream assessment sum of all domains
        List<AggregateResult> groupedResults2 = [select sum(Function_Points_Sum__c) from SEP_Domain2Assesment__c where SEP_Stream_Assessment__c = :streamID.to15()];
        Decimal streamFP = (Decimal) groupedResults2[0].get('expr0');
        System.debug('--> Update stream: stream FP = ' + streamFP + 'list size ' + groupedResults2.size() + '>>> ' + groupedResults2);
        
        SEP_Stream_Assessment__c sa = new SEP_Stream_Assessment__c();
        sa = [select Id, Function_Points_Sum__c from SEP_Stream_Assessment__c where Id = :streamID.to15()];
        sa.Function_Points_Sum__c = streamFP;
        update sa;
		
    }
    
    // calculate person days with CocomoII model (simplified)
    @AuraEnabled (cacheable=true)
    public static Double getCocPD(Double fp, String method) {
        System.debug('--> start calc cocPD with fp =  ' + fp);
        Double pd = 0;
        
        //=_coc_A*Power((_fp_ws1*_gear*_adj_ws1)/1000,_coc_E*_coc_EFM)*_coc_PDPM*_env
        //Cocomo etc constants -> to be moved to Custom Metatdata!!!
        final Double cocA = 2.94;
        final Double cocB = 0.91;
        final Double cocEFM = 1.0;
        final Double cocSF = 16.55;
        final Double cocE = cocB + (0.01 * cocSF);
        final Double cocPDPM = 19;
        final Double gear = 4.7;
        final Double adj = 1.0;
        final Double env = 1.2;
        
        Double base = (fp * gear * adj)/1000.0;
        Double exp = cocE*cocEFM;
        
        pd = cocA * Math.pow(base, exp) * cocPDPM * env;
        System.debug('--> calc cocPD = ' + pd);
        return pd;
    }
    
    @AuraEnabled (cacheable=true)
    public static Double getLinearPD(Double fp) {
        
        final Double a = 0.08;
        final Double b = 0.6;
        
        Double base = fp * a;
        Double exp = b * 2;
        Double pd = Math.pow(base,exp);
        
        return pd;
    }
    
    // calculate person days with Putnam model (simplified)
    @AuraEnabled (cacheable=true)
    public static Double getSlimPD(Double fp, Double duration, String method) {
        Double pd = 0;
        Double ck = 11; //maturity of dev orga, to be moved to custom metadata. Also known as PI
        
        Double l = Math.pow(fp, 3);
        Double c = Math.pow(ck,3);
        Double t = Math.pow(duration,4);
        
        pd = l/(c*t);
        return pd;
    }
    
    @AuraEnabled (cacheable=true)
    public static SEP_Method_Breakdown__mdt getMethodBreakdown (String methodName) {
        System.debug('--> custom data for = ' + methodName);
        SEP_Method_Breakdown__mdt breakdown = SEP_Method_Breakdown__mdt.getInstance(methodName);
        System.debug('--> custom data = ' + breakdown.DeveloperName);
        return breakdown;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getStreamsNdDomain2Assessments(String estimateId) {
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();
        if(String.isEmpty(estimateId)) return returnList;

        Map<Id, SEP_Domain2Assesment__c> domain2Assesments = new Map<Id, SEP_Domain2Assesment__c>([
            SELECT Id, Name, Function_Points_Sum__c,Total_of_Possible_Function_Points__c, Function_Point_Consumption__c, SEP_Domain__c, SEP_Domain__r.Name, SEP_Stream_Assessment__c, SEP_Stream_Assessment__r.Name 
            FROM SEP_Domain2Assesment__c 
            WHERE Estimate__c = :estimateId AND isActive__c = true 
            ORDER BY Name ASC
        ]);
        // Query all QA capabilities
        List<SEP_QA2Capability__c> qA2Capabilities = [
            SELECT ID, SEP_Assessment_ID__c, Selected_Answer__c FROM SEP_QA2Capability__c WHERE SEP_Assessment_ID__c IN :domain2Assesments.keySet()
        ];

        System.debug('Total QA2Capabilities: ' + qA2Capabilities.size());

        // Separate the QA2Capabilities into two maps
        Map<Id, Integer> allQMap = new Map<Id, Integer>();
        Map<Id, Integer> answeredQMap = new Map<Id, Integer>();
        for(SEP_QA2Capability__c qA2Capability : qA2Capabilities) {
            Id domain2AssessmentId = qA2Capability.SEP_Assessment_ID__c;
            allQMap.put(domain2AssessmentId, allQMap.containsKey(domain2AssessmentId) ? allQMap.get(domain2AssessmentId) + 1 : 1);
            if (qA2Capability.Selected_Answer__c != null) {
                answeredQMap.put(domain2AssessmentId, answeredQMap.containsKey(domain2AssessmentId) ? answeredQMap.get(domain2AssessmentId) + 1 : 1);
            }
        }

        // Compile the returnList
        for(SEP_Domain2Assesment__c domain2Assesment : domain2Assesments.values()) {
            Map<String, Object> recordDetails = new Map<String, Object>();
            recordDetails.put('record', domain2Assesment);
            recordDetails.put('answeredQSize', answeredQMap.containsKey(domain2Assesment.Id) ? answeredQMap.get(domain2Assesment.Id) : 0);
            recordDetails.put('allQSize', allQMap.containsKey(domain2Assesment.Id) ? allQMap.get(domain2Assesment.Id) : 0);
            returnList.add(recordDetails);
        }

        System.debug(returnList);
        return returnList;
    }


    @AuraEnabled(cacheable=true)
    public static List<SEP_Domain__c> getActiveDomains() {
        List<SEP_Domain__c> domains = [
            SELECT Id, Name, Estimated_Interview_Minutes__c, Parent_Domain__c 
            FROM SEP_Domain__c 
            WHERE Active__c = true
            ORDER BY Name ASC
        ];
        return domains.size() > 0 ? domains : null; 
    }

    @AuraEnabled(cacheable=true)
    public static String getOverallEngagementScopeId() {
        // Fetch Overall Engagement Scope Domain Record Id from the Custom Metadata SEP_Assessment_Helper__mdt
        SEP_Assessment_Helper__mdt assessmentHelper = SEP_Assessment_Helper__mdt.getInstance('Overall_Engagement_Scope_Id');
        return assessmentHelper.Record_Value__c;
    }

    @AuraEnabled
    public static List<SEP_Domain2Assesment__c> getActiveAssessmentDomains(String estimateId, String streamAssessmentId) {
        return getAssessmentDomains(estimateId, streamAssessmentId, true);
    }

    @AuraEnabled
    public static List<SEP_Domain2Assesment__c> getArchivedAssessmentDomains(String estimateId, String streamAssessmentId) {
        return getAssessmentDomains(estimateId, streamAssessmentId, false);
    }

    private static List<SEP_Domain2Assesment__c> getAssessmentDomains(String estimateId, String streamAssessmentId, Boolean isArchive) {
        List<SEP_Domain2Assesment__c> domain2Assesments = [
            SELECT Id, Name, isActive__c, SEP_Domain__c,Total_of_Possible_Function_Points__c, Function_Point_Consumption__c FROM SEP_Domain2Assesment__c 
            WHERE Estimate__c = :estimateId AND SEP_Stream_Assessment__c = :streamAssessmentId AND isActive__c = :isArchive 
            ORDER BY Name ASC
        ];
        return domain2Assesments.size() > 0 ? domain2Assesments : null;
    }

    @AuraEnabled
    public static String updateAssessmentDomains(List<SEP_Domain2Assesment__c> domain2Assesments){
        ResponseData responseData = new ResponseData();
        try {
            update domain2Assesments;
            responseData.isError = false;
            responseData.message = 'Successfully updated Assessment Domain records status!';
        } catch (Exception e) {
            responseData.isError = true;
            responseData.message = 'Failed to update Assessment Domain records status! ' + e.getMessage();
        }
        return JSON.serialize(responseData);
    }

    @AuraEnabled
    public static String createStreamAssessment(Map<String, String> assessment, SEP_Estimate__c estimate, List<SEP_Domain__c> selDomains, Boolean isInsert) {
        System.debug('SEP create Assessment record ---');
        ResponseData responseData = new ResponseData();
        String streamName = assessment.get('streamName');
        String overallEngScopeId = assessment.get('overallEngScopeId');
        String selStreamAssId = assessment.get('selStreamAssId');
        // Fetch Total_Allowed_Assessment from the Custom Metadata SEP_Assessment_Helper__mdt
        SEP_Assessment_Helper__mdt assessmentHelper = SEP_Assessment_Helper__mdt.getInstance('Total_Allowed_Assessment');
        Integer totalAllowedAssessment = Integer.valueOf(assessmentHelper.Record_Value__c);
        if(String.isEmpty(streamName) || String.isEmpty(overallEngScopeId) || estimate == null || selDomains.size() <= 0) {
            responseData.isError = true;
            responseData.message = 'Failed to create Stream Assessment because required fields are empty!';
            return JSON.serialize(responseData);
        }
        if(!isInsert && String.isEmpty(selStreamAssId)) {
            responseData.isError = true;
            responseData.message = 'Failed to add Domain because the selected Stream Assessment ID is null!';
            return JSON.serialize(responseData);
        }
        List<SEP_Stream_Assessment__c> streamAssessments = [SELECT Id, Name FROM SEP_Stream_Assessment__c WHERE Estimate__c = :estimate.Id];
        // Check if total number of allowed Assessment under an Estimate records is exceeded
        Integer totalStreams = streamAssessments.size();
        if(isInsert && (totalStreams >= totalAllowedAssessment)) {
            responseData.isError = true;
            responseData.message = 'Maximum ' + totalAllowedAssessment + ' Assessment record can be created in a single Estimate record! Total Assessment created = ' + totalStreams;
            return JSON.serialize(responseData);
        }
        // Check if a SteamAssessment record already exists with the submitted name
        for(SEP_Stream_Assessment__c streamAssessment : streamAssessments) {
            if(isInsert && (streamAssessment.Name == streamName)) {
                responseData.isError = true;
                responseData.message = 'An assessment record with the same name \'' + streamName +'\' already exists for the estimate \'' + estimate.Name + '\'. Please try again with a different assessment name!';
                return JSON.serialize(responseData);
            }
        }
        responseData = createAssessments(streamName, overallEngScopeId, estimate, selDomains, selStreamAssId, isInsert);
        return JSON.serialize(responseData);
    }

    private static ResponseData createAssessments(
        String streamName, 
        String overallEngScopeId, 
        SEP_Estimate__c estimate, 
        List<SEP_Domain__c> selDomains, 
        String selStreamAssId, 
        Boolean isInsert
    ) {
        ResponseData responseData = new ResponseData();
        // Remove Overall Engagement Scope domain for the selDomains List
        Boolean isOverEngStreamExists = true;
        SEP_Domain__c overEngDomain;
        SEP_Stream_Assessment__c overEngStream;
        String streamAssessmentId = selStreamAssId;
        // Start savepoint
        Savepoint sp = Database.setSavepoint();
        for (Integer i = selDomains.size() - 1; i >= 0; i--) {
            if (selDomains[i].Id == overallEngScopeId) {
                overEngDomain = selDomains.remove(i);
                break;
            }
        }
        /*
            Note: Create a separate Stream Assessment for the 'Overall Engagement Scope' domain.
            One single Estimate will have only one 'Overall Engagement Scope' record and it will 
            be idependent of other Stream Assessment.
        */
        // Check if 'Overall Engagement Scope' StreamAssessment record exists
        if(isInsert) {
            List<SEP_Stream_Assessment__c> overEngStreams = [
                SELECT Id, Name FROM SEP_Stream_Assessment__c 
                WHERE Name = :overEngDomain.Name AND Estimate__c = :estimate.Id
            ];
            isOverEngStreamExists = overEngStreams.size() <= 0 ? false : true;
            System.debug('SEP: OverallEngagementScope StreamAssessment record exists: ' + isOverEngStreamExists);
            // Fetch Stream Assessment Duration from the Custom Metadata SEP_Assessment_Helper__mdt
            SEP_Assessment_Helper__mdt assessmentHelper = SEP_Assessment_Helper__mdt.getInstance('Assessment_Duration');
            Double assessmentDuration = Decimal.valueOf(assessmentHelper.Record_Value__c);
            // Create SEP_Stream_Assessment__c record for the 'Overall Engagement Scope' domain
            if(isOverEngStreamExists) {
                overEngStream = overEngStreams[0];
            } else {
                overEngStream = new SEP_Stream_Assessment__c(
                    Name = overEngDomain.Name,
                    Estimate__c = estimate.Id,
                    SEP_Estimate_Name__c = estimate.Name,
                    Duration__c = assessmentDuration
                );
                try {
                    // Update 'Overall Engagement Scope' StreamAssessment if exists else create new
                    insert overEngStream;
                } catch (Exception e) {
                    responseData.isError = true;
                    responseData.message = 'Failed to create Stream Assessment record for the Overall Engagement Scope domain! ' + e.getMessage();
                    Database.rollback(sp);
                    return responseData;
                }
            }
            // Create SEP_Stream_Assessment__c records
            SEP_Stream_Assessment__c newStream = new SEP_Stream_Assessment__c(
                Name = streamName,
                Estimate__c = estimate.Id,
                SEP_Estimate_Name__c = estimate.Name,
                Duration__c = assessmentDuration
            );
            // Insert SEP_Stream_Assessment__c
            try {
                // Create new StreamAssessment for the other domains
                insert newStream;
            } catch (Exception e) {
                responseData.isError = true;
                responseData.message = 'Failed to create Stream Assessment record! ' + e.getMessage();
                Database.rollback(sp);
                return responseData;
            }
            streamAssessmentId = newStream.Id;
            estimate.Stage__c = 'Scoping in Progress';
            try {
                // Update Estimate Stage to 'Scoping in Progress' when Stream Assessment is created
                update estimate;
            } catch (Exception e) {
                responseData.isError = true;
                responseData.message = 'Failed to update Estimate Stage to Scope in Progress! ' + e.getMessage();
                Database.rollback(sp);
                return responseData;
            }
        }
        System.debug('SEP: StreamAssessment record exists: ' + isInsert +  ' Record Id: ' + streamAssessmentId);
        // Create Domain2Assessment records
        // Map<SEP_Domain__c, SEP_Domain2Assesment__c>
        Map<Id, SEP_Domain2Assesment__c> domain2Assessments = new Map<Id, SEP_Domain2Assesment__c>();
        for(SEP_Domain__c domain: selDomains) {
            domain2Assessments.put(
                domain.Id,
                new SEP_Domain2Assesment__c(
                    Name = domain.Name,
                    SEP_Domain__c = domain.Id,
                    Estimate__c = estimate.Id,
                    SEP_Stream_Assessment__c = streamAssessmentId
                )
            );
        }
        // Create Domain2Assesments for the OverallEngagementScope StreamAssessment if doesn't exist
        if(!isOverEngStreamExists) {
            domain2Assessments.put(
                overEngDomain.Id,
                new SEP_Domain2Assesment__c(
                    Name = overEngDomain.Name,
                    Estimate__c = estimate.Id,
                    SEP_Domain__c = overEngDomain.Id,
                    SEP_Stream_Assessment__c = overEngStream.Id
                )
            );
        }
        Set<Id> domainIds = domain2Assessments.keySet();
        // Insert Domain2Assessment
        try {
            insert domain2Assessments.values();
        } catch (Exception e) {
            responseData.isError = true;
            responseData.message = 'Failed to create Domain2Assessment records! ' + e.getMessage();
            Database.rollback(sp);
            return responseData;
        }
        System.debug('SEP: Total ' + domain2Assessments.size() + ' Domain2Assesment records created!');
        // Fetch all Capability records realted to the selected Domains
        Set<Id> capabilityIds = new Set<Id>();
        // Create SEP_Capability2Domain__c records
        List<SEP_Capability2Domain__c> capability2Domains = new List<SEP_Capability2Domain__c>();
        for (SEP_Capability__c  capability: [
            SELECT Id, Name, SEP_Domain__c FROM SEP_Capability__c WHERE SEP_Domain__c IN :domainIds AND Active__c = True
        ]) {
            capabilityIds.add(capability.Id);
            capability2Domains.add(
                new SEP_Capability2Domain__c(
                    SEP_Capability__c = capability.Id,
                    SEP_Domain2Assesment__c = domain2Assessments.get(capability.SEP_Domain__c).Id
                )
            );
        }
        // Insert Capability2Domain
        try {
            insert capability2Domains;
        } catch (Exception e) {
            responseData.isError = true;
            responseData.message = 'Failed to create Capability2Domains records! ' + e.getMessage();
            Database.rollback(sp);
            return responseData;
        }
        System.debug('SEP: Total ' + capability2Domains.size() + ' Capability2Domain records created!');
        // Map<Domain2AssesmentId, Map<CapabilityId, Capability2DomainId>
        Map<Id, Map<Id, Id>> domain2CapIds = new Map<Id, Map<Id, Id>>();
        for(SEP_Capability2Domain__c capability2Domain: capability2Domains) {
            if(domain2CapIds.containsKey(capability2Domain.SEP_Domain2Assesment__c)) {
                Map<Id, Id> cap2domain = domain2CapIds.get(capability2Domain.SEP_Domain2Assesment__c);
                cap2domain.put(capability2Domain.SEP_Capability__c, capability2Domain.Id);
            } else {
                domain2CapIds.put(
                    capability2Domain.SEP_Domain2Assesment__c,
                    new Map<Id, Id>{capability2Domain.SEP_Capability__c => capability2Domain.Id}
                );
            }
        }
        // Fetch all QuestionAnswers based on Capabilities and Domains
        List<SEP_QA2Capability__c> qA2Capabilities = new List<SEP_QA2Capability__c>();
        for(SEP_Question_Answers__c questionAnswer: [
            SELECT Id, Name, SEP_Capability__c, SEP_Domain__c 
            FROM SEP_Question_Answers__c 
            WHERE SEP_Capability__c IN :capabilityIds AND SEP_Domain__c IN :domainIds AND Active__c = True
        ]) {
            // Get Domain2Assesment record by domainId from the map domain2Assessments
            SEP_Domain2Assesment__c dom2Assessment = domain2Assessments.get(questionAnswer.SEP_Domain__c);
            Map<Id, Id> capVscap2Domain = domain2CapIds.get(dom2Assessment.Id);
            // Get Capability2Domain Id from the map domain2CapIds by Capability Id
            Id cap2DomainId = capVscap2Domain.get(questionAnswer.SEP_Capability__c);
            if(!String.isBlank(cap2DomainId)) {
                // Create SEP_QA2Capability__c records
                qA2Capabilities.add(
                    new SEP_QA2Capability__c(
                        SEP_Capability2Domain__c = cap2DomainId,
                        SEP_Question_Answer__c = questionAnswer.Id,
                        Estimate__c = estimate.Id,
                        Stream_Assessment__c = streamAssessmentId
                    )
                );
            }
        }
        // Insert SEP_QA2Capability__c
        try {
            insert qA2Capabilities;
        } catch (Exception e) {
            responseData.isError = true;
            responseData.message = 'Failed to create QA2Capability records! ' + e.getMessage();
            Database.rollback(sp);
            return responseData;
        }
        System.debug('SEP: Total ' + qA2Capabilities.size() + ' QA2Capability records created!');
        // Return success response
        responseData.isError = false;
        responseData.message = 'Guided Scoping Workstream Assessment successfully created!';
        return responseData;
        
    }

    private class ResponseData {
        Boolean isError;
        String message;
    }
}