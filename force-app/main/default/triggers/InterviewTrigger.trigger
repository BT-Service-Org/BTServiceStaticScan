trigger InterviewTrigger on Interview__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    Set<Id> candidateIds = new Set<Id>();
    Set<Interview__c> interviews = new Set<Interview__c>();
    Map<Id, Interview__c> interviewMap = new Map<Id, Interview__c>();

    // Added additional conditions as trigger handles more events

 if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {

            // Add interview candidates to set of Ids to roll up
            // Add interviews with non-null recommendations to set to set candidate status
            // Add interviews with non-null interviewers to the map to grant sharing
            for(Interview__c iv: Trigger.new)
            {
                if (iv.Actual_Interview_Date__c != null)
                {

                    Interviewutilities.UpdateDatesonRecruit(trigger.new);
                }
                
                candidateIds.add(iv.Candidate__c);
                if(iv.Recommendation__c != null)
                {
                    interviews.add(iv);
                }
                if(iv.Interviewer__c != null)
                {
                    interviewMap.put(iv.Id, iv);
                }
            }   
            
            InterviewUtilities.CreateInterviewEvaluations(Trigger.New, candidateIds);
        }
        else if(Trigger.isUpdate)
        {
            // Add interview candidates to set of Ids to roll up
            // Add interviews with non-null interviewers to the map to grant sharing
            // Add interviews with non-null interviewers to the map to grant sharing
            for(Interview__c iv: Trigger.new)
            {
                if (iv.Actual_Interview_Date__c != null)
                {

                    Interviewutilities.UpdateDatesonRecruit(trigger.new);
                }
                
                Interview__c oldInterview = Trigger.oldMap.get(iv.Id);
                if(iv.Overall_Interview_Score__c != oldInterview.Overall_Interview_Score__c)
                {
                    candidateIds.add(iv.Candidate__c);
                }
                // catch case of reparenting (shouldn't happen)
                if(iv.Candidate__c != oldInterview.Candidate__c)
                {
                    candidateIds.add(iv.Candidate__c);
                    candidateIds.add(oldInterview.Candidate__c);
                }
                
                // if recommendation changes from null to having a value or opposite
                // score will need to be included or removed from rollup scores
                if((iv.Recommendation__c != null && oldInterview.Recommendation__c==null) 
                   ||(iv.Recommendation__c == null && oldInterview.Recommendation__c!=null) )
                {
                    candidateIds.add(iv.Candidate__c);
                }
                
                if(iv.Recommendation__c != null && iv.Recommendation__c != oldInterview.Recommendation__c)
                { 
                    interviews.add(iv);
                }
                // interviewer assignments
                if(iv.Interviewer__c != oldInterview.Interviewer__c ||
                   iv.Interviewer2__c != oldInterview.Interviewer2__c ||
                   iv.Interviewer3__c != oldInterview.Interviewer3__c ||
                   iv.Interviewer4__c != oldInterview.Interviewer4__c ||
                   iv.Interviewer5__c != oldInterview.Interviewer5__c)
                {
                    interviewMap.put(iv.Id, iv);
                }
            } 
        }
        else if(Trigger.isDelete)
        {
            // Add interview candidates to set of Ids to roll up
            for(Interview__c iv: Trigger.old)
            {
                candidateIds.add(iv.Candidate__c);
            } 
        }
        else if(Trigger.isUndelete)
        {
            // Add interview candidates to set of Ids to roll up
            // Add interviews with non-null interviewers to the map to grant sharing
            for(Interview__c iv: Trigger.new)
            {
                candidateIds.add(iv.Candidate__c);
                interviewMap.put(iv.Id, iv);
            } 
        }
        if(!candidateIds.isEmpty())
        {
            InterviewUtilities.RollupInterviewScores(candidateIds);
        }
        if(!interviews.isEmpty())
        {
            InterviewUtilities.UpdateCandidateStatus(interviews);
        }
        if(!interviewMap.isEmpty())
        {
           InterviewUtilities.AddInterviewShares(interviewMap);
        }
    }
    else
    {
        if(Trigger.isDelete)
        {
            // Add interview candidates to set of Ids to roll up
            for(Interview__c iv: Trigger.old)
            {
                interviewMap.put(iv.Id, iv);
            } 
            if(!interviewMap.isEmpty())
            {
                InterviewUtilities.RemovePanelInterviewShares(interviewMap);
            }    
        }
    } 
}