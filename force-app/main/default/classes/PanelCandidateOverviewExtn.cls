public class PanelCandidateOverviewExtn 
{
    public class InterviewWithEvaluations
    {
        private Interview__c interview;
        private string interviewType;
        private List<Interview_Evaluation__c> interviewEvaluations;
        
        public InterviewWithEvaluations(Interview__c interview)
        {
            this.interview = interview;
            interviewType = loadInterviewType();
        }
        
        public Interview__c getInterview()
        {
            return interview;
        }
        
        public string getInterviewType() {
            return interviewType;
        }
        
        public string loadInterviewType()
        {
            if(interviewType == null)
            {
                interviewType = InterviewUtilities.GetRecordTypes('Interview__c').get(interview.RecordTypeId).Name;
            }
            return interviewType;
        }
        
        public List<Interview_Evaluation__c> getInterviewEvaluations()
        {
            if(interviewEvaluations == null)
            {
                interviewEvaluations = [select Id, Interview_Question__r.Domain__c, Interview_Question__r.Question__c, Score__c, Rating__c, 
                                        Comments__c, Interview_Question__r.Sort_Order__c, Skipped__c
                                        from Interview_Evaluation__c
                                        where Interview__c =: interview.Id
                                        order by Interview_Question__r.Sort_Order__c, Interview_Question__r.Domain__c nulls last];
            }
            return interviewEvaluations;
        }
    }
    
    private Interview_Candidate__c interviewCandidate;
    private List<InterviewWithEvaluations> allInterviews;
    private Id lastInterviewId;
    private Id interviewCandidateId;
    
    public PanelCandidateOverviewExtn() {}
    
    public PanelCandidateOverviewExtn(ApexPages.StandardController stdController) 
    {
        interviewCandidate = (Interview_Candidate__c)stdController.getRecord();
        interviewCandidateId = interviewCandidate.Id;
    }

    private PanelCandidateOverviewExtn(Id icId)
    {
        interviewCandidateId = icId;
    }
    
    public List<InterviewWithEvaluations> getAllInterviews()
    {
        if(allInterviews == null)
        {
            allInterviews = new List<InterviewWithEvaluations>();
            for(Interview__c interview: [select Id, Actual_Interview_Date__c, Interviewer__r.Name, Comments__c, Recommendation__c, Overall_Interview_Score__c, Overall_Interview_Rating__c, RecordTypeId
                                         from Interview__c
                                         where Candidate__c =: interviewCandidateId
                                         order by LastModifiedDate desc])
            {
                allInterviews.add(new InterviewWithEvaluations(interview));   
            }
        }
        return allInterviews;
    }
    
    public boolean getHasInterviews() {
        return getAllInterviews().size() > 0;
    }
    
    public Id getLastInterviewId()
    {
        return getAllInterviews().get(getAllInterviews().size() - 1).Interview.Id;
    }
    
    @RemoteAction
    public static List<InterviewWithEvaluations> getAllInterviewsForId(Id interviewCandidateId) 
    {
        return new PanelCandidateOverviewExtn(interviewCandidateId).getAllInterviews();
    }
}