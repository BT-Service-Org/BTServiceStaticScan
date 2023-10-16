global class InterviewUtilities 
{
    // Get a Map of RecordType for a given object
    public static Map<Id, RecordType> GetRecordTypes(string sObjectName)
    {
        return new Map<Id, RecordType>([select Id, Name, DeveloperName from RecordType where SObjectType =: sObjectname]);
    }
    
    public static void createInterviewEvaluations(List<Interview__c> interviews, Set<Id> candidateIds)
    {
        Map<String, List<Interview_Question__c>> questionCache = new Map<String, List<Interview_Question__c>>();
        List<Interview_Evaluation__c> interviewEvaluations = new List<Interview_Evaluation__c>();
        
        Map<Id, Interview_Candidate__c> positions = new Map<Id, Interview_Candidate__c>(
            [select Id, position__c from Interview_Candidate__c where id in :candidateIds]);
    
        for(Interview__c interview: interviews)
        {
            String position = positions.get(interview.Candidate__c).Position__c;
            String recordTypeName = interview.RecordTypeName__c; // note use of record type name from interview record, not developer name from record type
            String questionCacheKey = position + recordTypeName;
            
            List<Interview_Question__c> questions = questionCache.get(questionCacheKey);
            if (questions == null)
            {
                questions = InterviewQuestionUtilities.getActiveQuestions(position, recordTypeName);
                questionCache.put(questionCacheKey, questions);
            }
            
            addEvaluationsForInterview(interviewEvaluations, interview, questions);
        }
        
        if(interviewEvaluations.Size() > 0)
        {
            insert interviewEvaluations;
        }
    }
    
    private static void addEvaluationsForInterview(List<Interview_Evaluation__c> interviewEvaluations, Interview__c interview, List<Interview_Question__c> questions)
    {
        for(Interview_Question__c question: questions)
        {
            Interview_Evaluation__c evaluation = new Interview_Evaluation__c
            (
                Interview__c = interview.Id, 
                Interview_Question__c = question.Id
            );
            interviewEvaluations.add(evaluation);
        }
    }

    public static void RollupInterviewScores(Set<Id> candidateIds)
    {
        Map<Id, RecordType> interviewRecordType = GetRecordTypes('Interview__c');
        Map<Id,Interview_Candidate__c> candidates = new Map<Id,Interview_Candidate__c>();
        decimal averageConsultingScore = 0;
        decimal averageTechnicalScore = 0;
        Id lastCandidateId = null;
        Interview_Candidate__c candidate;
        for(AggregateResult ar: [select Candidate__c, RecordTypeId, avg(Overall_Interview_Score__c) AverageScore
                                from Interview__c
                                where Candidate__c in :candidateIds and Recommendation__c != null
                                group by Candidate__c, RecordTypeId
                                order by Candidate__c, RecordTypeId])
        {
            Id currentCandidateId = (Id)ar.get('Candidate__c');
            string recordTypeDeveloperName = interviewRecordType.get((Id)ar.get('RecordTypeId')).DeveloperName;
            decimal averageScore = (decimal)ar.get('AverageScore');
            if(lastCandidateId != currentCandidateId)
            {
                averageConsultingScore = 0;
                averageTechnicalScore = 0;
                lastCandidateId = currentCandidateId;
                candidates.put(currentCandidateId, new Interview_Candidate__c(Id = currentCandidateId));
            }

            if(recordTypeDeveloperName == 'Consulting_Interview')
            {
                averageConsultingScore = averageScore;
            }
            else if(recordTypeDeveloperName == 'Technical_Interview')
            {
                averageTechnicalScore = averageScore;
            }
            candidates.get(currentCandidateId).Consulting_Interview_Score__c = averageConsultingScore;
            candidates.get(currentCandidateId).Technical_Interview_Score__c = averageTechnicalScore;
        }

        // Find candidates without any interviews (rare)
        for(Id cId: candidateIds)
        {
            if(!candidates.containsKey(cId))
            {
                candidates.put(cId, new Interview_Candidate__c(Id = cId, Consulting_Interview_Score__c = 0.0, Technical_Interview_Score__c = 0.0));
            }    
        }

        if(candidates.keySet().size() > 0)
        {
            update candidates.values();
        }
    }
 
    public static void UpdateCandidateStatus(Set<Interview__c> interviews)
    {
        Map<Id, Interview_Candidate__c> candidatesMap = new Map<Id, Interview_Candidate__c>();
        for(Interview__c intv: interviews)
        {
            if(intv.Recommendation__c != null)
            {
                string interviewType = GetRecordTypes('Interview__c').get(intv.RecordTypeId).DeveloperName;
                Interview_Candidate__c candidate = candidatesMap.containsKey(intv.Candidate__c) ? candidatesMap.get(intv.Candidate__c) :
                                                    new Interview_Candidate__c(Id = intv.Candidate__c);
                if(intv.Recommendation__c == 'No')
                {
                    candidate.Rejected__c = true;
                }
                else if(intv.Recommendation__c == 'Yes' && interviewType == 'Consulting_Interview')
                {
                    candidate.Passed_Consulting__c = true;
                }
                else if(intv.Recommendation__c == 'Yes' && interviewType == 'Technical_Interview')
                {
                    candidate.Passed_Technical__c = true;
                }
                candidatesMap.put(candidate.Id, candidate);
            }
        }

        if(!candidatesMap.isEmpty())
        {
            update candidatesMap.values();
        }
    }

    public static void AddInterviewShares(Map<Id, Interview__c> interviewMap)
    {
        List<Interview__Share> newInterviewShares = new List<Interview__Share>();
        List<Interview__Share> oldInterviewShares = [select Id from Interview__Share
                                                    where ParentId in: interviewMap.keySet() 
                                                    and RowCause =: Schema.Interview__Share.RowCause.Interviewer__c];
        List<Interview__Share> oldPanelInterviewShares = new List<Interview__Share>();                                            
        Map<Id, List<Id>> candidateToPanelInterviewerMap = new Map<Id, List<Id>>();   
        Map<Id, Interview__c> relatedInterviewMap = new Map<Id, Interview__c>();  
        Set<Id> candidateID = new Set<Id>();   
        Set<Id> panelInterviewIDs = new Set<Id>();                                    

        for(Interview__c iv: interviewMap.values())
        {
            if(iv.Interviewer__c != null)
            {
                newInterviewShares.add(new Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer__c));                                            
            }
            candidateID.add(iv.Candidate__c);
        }

        // Handle panel Interviewers
        for (Interview__c iv: [SELECT Id, Candidate__c, Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c From Interview__c Where Candidate__c IN:candidateID AND RecordTypeName__c='Panel Interview'])
        {
            List<Id> panelInterviewers = new List<Id>();
            if(iv.Interviewer__c != null)
                panelInterviewers.add(iv.Interviewer__c);
            
            if(iv.Interviewer2__c != null)
            {
                newInterviewShares.add(new Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer2__c));
                panelInterviewers.add(iv.Interviewer2__c);
            }    
            if(iv.Interviewer3__c != null)
            {
                newInterviewShares.add(new Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer3__c));
                panelInterviewers.add(iv.Interviewer3__c);
            } 
            if(iv.Interviewer4__c != null)
            {
                newInterviewShares.add(new Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer4__c));
                panelInterviewers.add(iv.Interviewer4__c);
            } 
            if(iv.Interviewer5__c != null)
            {
                newInterviewShares.add(new Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer5__c));
                panelInterviewers.add(iv.Interviewer5__c);
            } 
            
            // Add the candidates that has panel Interviews
            candidateToPanelInterviewerMap.put(iv.Candidate__c, panelInterviewers);
            panelInterviewIDs.add(iv.Id);
        }
        
        // Check whether have any panel interview, if yes select the related interviews
        if (!candidateToPanelInterviewerMap.isEmpty())
        {
            relatedInterviewMap = new Map<Id, Interview__c>([SELECT Id, Candidate__c from Interview__c where Candidate__c In: candidateToPanelInterviewerMap.keySet() AND Id Not In:panelInterviewIDs]);    
            // Select old Panel Interview Shares
            if (!relatedInterviewMap.isEmpty())   
            {
                oldPanelInterviewShares = [select Id from Interview__Share
                                           where ParentId in: relatedInterviewMap.keySet() 
                                           and RowCause =: Schema.Interview__Share.RowCause.Panel_Interviewer__c];
                // Loop through the relatedIDs
                for (Interview__c iv: relatedInterviewMap.values())
                {
                    // Loop through the Panel Interviewers and add them
                    for (Id panelInterviewer: candidateToPanelInterviewerMap.get(iv.Candidate__c))
                    {
                        newInterviewShares.add(new Interview__Share(AccessLevel = 'Read', ParentId = iv.Id, 
                                                            RowCause = Schema.Interview__Share.RowCause.Panel_Interviewer__c, UserOrGroupId = panelInterviewer));    
                    }
                }                          
            }
        }

        if (!oldPanelInterviewShares.isEmpty())
            delete oldPanelInterviewShares;
        delete oldInterviewShares;
        insert newInterviewShares;
    }
    
    public static void RemovePanelInterviewShares(Map<Id, Interview__c> interviewMap)
    {
        List<Interview__Share> oldPanelInterviewShares = new List<Interview__Share>();                                            
        Map<Id, List<Id>> candidateToPanelInterviewerMap = new Map<Id, List<Id>>();   
        Map<Id, Interview__c> relatedInterviewMap = new Map<Id, Interview__c>();                                         

        // Handle panel Interviewers
        for (Interview__c iv: [SELECT Id, Candidate__c, Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c From Interview__c Where Id IN:interviewMap.keySet() AND RecordTypeName__c='Panel Interview'])
        {
            List<Id> panelInterviewers = new List<Id>();
            if(iv.Interviewer__c != null)
                panelInterviewers.add(iv.Interviewer__c);
            
            if(iv.Interviewer2__c != null)
            {
                panelInterviewers.add(iv.Interviewer2__c);
            }    
            if(iv.Interviewer3__c != null)
            {
                panelInterviewers.add(iv.Interviewer3__c);
            } 
            if(iv.Interviewer4__c != null)
            {
                panelInterviewers.add(iv.Interviewer4__c);
            } 
            if(iv.Interviewer5__c != null)
            {
                panelInterviewers.add(iv.Interviewer5__c);
            } 
            
            // Add the candidates that has panel Interviews
            candidateToPanelInterviewerMap.put(iv.Candidate__c, panelInterviewers);
        }
        
        // Check whether have any panel interview, if yes select the related interviews
        if (!candidateToPanelInterviewerMap.isEmpty())
        {
            relatedInterviewMap = new Map<Id, Interview__c>([SELECT Id, Candidate__c from Interview__c where Candidate__c In: candidateToPanelInterviewerMap.keySet() AND Id Not In:interviewMap.keySet()]);    
            // Select old Panel Interview Shares
            if (!relatedInterviewMap.isEmpty())   
            {
                oldPanelInterviewShares = [select Id from Interview__Share
                                           where ParentId in: relatedInterviewMap.keySet() 
                                           and RowCause =: Schema.Interview__Share.RowCause.Panel_Interviewer__c];               
            }
        }

        if (!oldPanelInterviewShares.isEmpty())
            delete oldPanelInterviewShares;
    }
    
       public static void UpdateDatesonRecruit(List<Interview__c> interviews)
    {
        
        List <Interview_Candidate__c> RecruitUpdate = new List<Interview_Candidate__c>();
        
        for(Interview__c intvs: interviews)
        {

            AggregateResult[] FirstScreenDate = [select Min(Actual_Interview_Date__c)
                                                 from Interview__c
                                                where Candidate__c = :intvs.Candidate__c 
                                                 and Actual_interview_date__c != null];
            
                        
            if (DateTime.valueOf(FirstScreenDate[0].get('expr0')) != null && intvs.RecordTypeName__c == 'Panel Interview') 
            {
                RecruitUpdate.add(new Interview_Candidate__c(Id =intvs.Candidate__c , First_Screen_Date__c = DateTime.valueOf(FirstScreenDate[0].get('expr0')),
                                                            Panel_Interview_Date__c = intvs.Actual_interview_date__c));
            }
            else
                RecruitUpdate.add(new Interview_Candidate__c(Id =intvs.Candidate__c , First_Screen_Date__c = DateTime.valueOf(FirstScreenDate[0].get('expr0'))
                                                            ));
            
            
            
        }
        update RecruitUpdate;
    }
}