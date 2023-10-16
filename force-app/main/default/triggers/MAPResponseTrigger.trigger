trigger MAPResponseTrigger on MAPResponse__c (after insert, before update) {
    Map<Id, MAPInterview__c> interviews = new Map<Id, MAPInterview__c>();
    Map<Id, MAPInterviewDimension__c> targets = new Map<Id, MAPInterviewDimension__c>();
    Set<ID> ids = Trigger.newMap.keySet();
    List<MAPResponse__c> workingSet = [SELECT Id, Interview__c FROM MAPResponse__c WHERE Id in :ids];
    
    for (MAPResponse__c r : workingSet)
    {
        if (interviews.containsKey(r.Interview__c))
            continue;
        
        // Retrieve Interview & Associated Interview Dimensions
        MAPInterview__c interview = 
            [SELECT 
                 Id,
                 Level__c,
                 Score__c,
                 Persona__r.Domain__r.Id,
                 Persona__r.Domain__r.Tier_1_Min__c,
                 Persona__r.Domain__r.Tier_1_Max__c,
                 Persona__r.Domain__r.Tier_2_Min__c,
                 Persona__r.Domain__r.Tier_2_Max__c,
                 Persona__r.Domain__r.Tier_3_Min__c,
                 Persona__r.Domain__r.Tier_3_Max__c,
                 Persona__r.Domain__r.Tier_4_Min__c,
                 Persona__r.Domain__r.Tier_4_Max__c,
                 Persona__r.Domain__r.Tier_5_Min__c,
                 Persona__r.Domain__r.Tier_5_Max__c,
                 (
                     SELECT
                         Id,
                         Name,
                         Level__c,
                         Score__c,
                         Score_Goal__c,
                         Skip__c,
                         Dimension__r.Id, Dimension__r.Name, Dimension__r.Count__c, Dimension__r.Weight__c, Dimension__r.Score_Max__c
                     FROM
                         Interview_Dimensions__r
                    WHERE
                        Skip__c != TRUE
                 )
             FROM
                 MAPInterview__c 
             WHERE 
                 Id= :r.Interview__c];

        interviews.put(r.Interview__c, interview);
        
        // Variables
        MAPDomain__c domain = interview.Persona__r.Domain__r;
        MAPInterviewDimension__c[] interviewDims = interview.Interview_Dimensions__r;
        
        // Process each Interview Dimension
        for (MAPInterviewDimension__c dim : interviewDims)
        {
            System.debug(dim);

            MAPResponse__c[] responses = 
                [SELECT
                    Id,
                    Score__c,
                    Skip__c,
                    Current_State__r.Level__c,
                    Goal_State__r.Level__c,
                    Capability__r.Id,
                    Capability__r.Name,
                    Question__r.Id,
                    Question__r.Weight__c,
                    Question__r.Sequence__c
                FROM
                    MAPResponse__c
                WHERE
                    Interview_Dimension__c = :dim.Id];
            
            // Build Capability Map 
            Map<Id, MAPCapability__c> capabilities = new Map<Id, MAPCapability__c>();
            
            for (MAPResponse__c response : responses)
            {
                MAPCapability__c cap = response.Capability__r;

                if (!capabilities.containsKey(cap.Id))
                    capabilities.put(cap.Id, cap);
            }
            
            // Build Response Map
            Map<Id, List<MAPResponse__c>> capResponses = new Map<Id,List<MAPResponse__c>>();
            
            for (MAPResponse__c response : responses)
            {
                Id key = response.Capability__c;
                if (!capResponses.containsKey(key))
                    capResponses.put(key, new List<MAPResponse__c>());
                
                List<MAPResponse__c> target = capResponses.get(key);
                
                if (!target.contains(response))
                    target.add(response);
            }
            
            // Score Interview Dimension
            dim.Score__c = 0.0;
            Decimal tally = 0.0;
            Decimal tallyGoal = 0.0;
            Decimal maxScore = dim.Dimension__r.Score_Max__c;
            
            // Score each Capability in Dimension
            for (Id key : capResponses.keySet())
            {
                MAPCapability__c cap = capabilities.get(key);
                MAPResponse__c[] target = capResponses.get(key);
                
                Integer questionCount = target.size();
                Decimal current = 0.0;
                Decimal goal = 0.0;
                
                for (MAPResponse__c response : target)
                {
                   // score = score + response.Score__c + response.Question__r.Weight__c;
                   
                   if (response.Skip__c)
                   {
                      questionCount = questionCount - 1;
                   }
                   else
                   {
                       current = current + MAPScoringEngine.CalculateScore(response.Current_State__r.Level__c) + response.Question__r.Weight__c;
                       goal = goal + MAPScoringEngine.CalculateScore(response.Goal_State__r.Level__c) + response.Question__r.Weight__c;
                   }

                  //score = score + MAPScoringEngine.CalculateScore(response.Current_State__r.Level__c) + response.Question__r.Weight__c;
                }
                
                Decimal computed = (questionCount == 0) ? 0 : (current / questionCount).setScale(2);
                Decimal computedGoal = (questionCount == 0) ? 0 : (goal / questionCount).setScale(2);
                
                //Decimal computed = (score / questionCount).setScale(2);
 
                tally = tally + computed;
                tallyGoal = tallyGoal + computedGoal;
            }
            
            Decimal dimCurrent = ((tally / maxScore) * 100).setScale(2);
            dimCurrent = dimCurrent.round(RoundingMode.DOWN);
            
            Decimal dimGoal = ((tallyGoal / maxScore) * 100).setScale(2);
            dimGoal = dimGoal.round(RoundingMode.DOWN);
                       
            dim.Level__c = MAPScoringEngine.CalculateLevel(dimCurrent, domain);
            dim.Score__c = dimCurrent;
            dim.Score_Goal__c = dimGoal;

            System.debug ('AD Id: ' + dim.Name +
                         ' - Dimension: ' + dim.Dimension__r.Name +
                         ' - Level: ' + dim.Level__c +
                         ' - # of Capabilities: ' + capabilities.size() +
                         ' - Score: ' + dim.Score__c + '%' +
                         ' - Goal: ' + dim.Score_Goal__c + '%' +
                         ' - Weight: ' + dim.Dimension__r.Weight__c + 
                         ' - Tally: ' + tally +
                         ' - Max: ' + maxScore);
            
            if (!targets.containsKey(dim.Id))
            {
                targets.put(dim.Id, dim);
            }
        }
        
        // Score Assessment
        MAPScoringEngine.CalculateLevel(interview, domain, interviewDims);
        
        System.Debug('* Assessment * : ' + interview.Score__c + ' - ' + interview.Level__c);
    }
    
    System.debug('Dimensions to update: ' + targets.size());
    
    if (targets.size() > 0)
        update targets.values();
    
    if (interviews.size() > 0)
        update interviews.values();
}