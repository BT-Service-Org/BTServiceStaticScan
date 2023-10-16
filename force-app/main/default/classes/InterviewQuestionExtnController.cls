public class InterviewQuestionExtnController
{
    public class InterviewAssessment
    {
        public string scoreString
        {
            get
            {
                if(evaluation.Score__c != null)
                {
                    return (evaluation.Score__c > 3 ? 4 : evaluation.Score__c).format();
                }
                else
                {
                    return '';
                }
            }
            set
            {
                if(value != '')
                {
                    evaluation.Score__c = integer.valueOf(value);
                }
            }
        }
        public Interview_Evaluation__c evaluation { get; set; }

        public InterviewAssessment(Interview_Evaluation__c ie)
        {
            evaluation = ie;
        }
    }

    public Interview__c iAssessment { get; set; }
    public List<InterviewAssessment> assessments { get; set; }
    public Recruiting_Scoring__c recruitingScores { get; private set; }
    public List<SelectOption> ratings
    {
        get
        {
            if(ratings == null)
            {
                ratings = new List<SelectOption>();
                ratings.add(new SelectOption(recruitingScores.Rating1_Score_Value__c.format(), recruitingScores.Rating1_Score_Label__c));
                ratings.add(new SelectOption(recruitingScores.Rating2_Score_Value__c.format(), recruitingScores.Rating2_Score_Label__c));
                ratings.add(new SelectOption(recruitingScores.Rating3_Score_Value__c.format(), recruitingScores.Rating3_Score_Label__c));
                ratings.add(new SelectOption(recruitingScores.Rating4_Score_Value__c.format(), recruitingScores.Rating4_Score_Label__c));
            }
            return ratings;
        }
        set;
    }
    private ApexPages.StandardController stdCtrl;

    public InterviewQuestionExtnController(ApexPages.StandardController stdCtrl)
    {

        this.stdCtrl = stdCtrl;

        recruitingScores = Recruiting_Scoring__c.getOrgDefaults();
                             
        iAssessment = (Interview__c) stdCtrl.getRecord();
        if(assessments == null)
        {
            assessments = new List<InterviewAssessment>();
            for(Interview_Evaluation__c ie: [select id, Comments__c, Score__c, Skipped__c,
                                                       Interview_Question__r.Domain__c,
                                                       Interview_Question__r.Question__c, Interview_Question__r.Question_Category__c ,
                                                       Interview_Question__r.Rating1_Definition__c, Interview_Question__r.Rating2_Definition__c,
                                                       Interview_Question__r.Rating3_Definition__c, Interview_Question__r.Rating4_Definition__c
                                                       from Interview_Evaluation__c
                                                       where interview__c = :iAssessment.id
                                                       order by Interview_Question__r.Sort_Order__c, Interview_Question__r.Domain__c nulls last])
            {
                assessments.add(new InterviewAssessment(ie));
            }
        }
    }

    public string interviewType
    {
        get
        {
            if(interviewType == null)
            {
                interviewType = InterviewUtilities.GetRecordTypes('Interview__c').get(iAssessment.RecordTypeId).DeveloperName;
            }
            return interviewType;
        }
        set;
    }

    public PageReference saveScores()
    {
        calcScore();

        Savepoint sp = Database.setSavepoint();
        try
        {
            doSave();
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Scores saved successfully!!!'));
        return null;
    }

    private void calcScore()
    {
        decimal overallScore = 0;
        integer overallCount = 0;

        for (InterviewAssessment iac: assessments )
        {
            if((!iac.evaluation.Skipped__c) && iac.evaluation.Score__c > 0)
            {
                overallScore = iac.evaluation.Score__c + overallScore;
                overallCount++;
            }
        }

        if(overallCount > 0)
        {
            iAssessment.Overall_Interview_Score__c = overallScore / overallCount;
        }
    }

    private void doSave()
    {
        List<Interview_Evaluation__c> evals = new List<Interview_Evaluation__c>();
        for(InterviewAssessment ia: assessments)
        {
            if(iAssessment.Recommendation__c != null && (string.IsEmpty(ia.evaluation.Comments__c) || ia.evaluation.Score__c == null)  && ! ia.evaluation.Skipped__c)
            {
                throw new CustomException('A comment and rating must be entered for each objective');
            }
            evals.add(ia.evaluation);
        }
        update evals;
        update iAssessment;
    }
}