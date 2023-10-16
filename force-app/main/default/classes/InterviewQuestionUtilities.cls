global class InterviewQuestionUtilities 
{
    public static final String DEFAULT_POSITION = 'Default';
    
    static webservice string RenumberQuestions(string questionCategory)
    {
        string resultStr = '';
        List<Interview_Question__c> renumberedQuestions = new List<Interview_Question__c>();
        integer i = 1;
        for(Interview_Question__c iq: [select Id from Interview_Question__c where Question_Category__c =: questionCategory and Active__c = true
                                       order by Sort_Order__c, Domain__c, LastModifiedDate desc nulls last])
        {
            iq.Sort_Order__c = i;
            renumberedQuestions.add(iq);
            i++;
        }
        
        if(renumberedQuestions.size() > 0)
        {
            try
            {
                update renumberedQuestions;
                resultStr = questionCategory + ' Renumbered';
            }
            catch(Exception ex)
            {
                resultStr = ex.getMessage();
            }
        }
        else
        {
            resultStr = 'No questions to renumber';
        }
        
        return resultStr;
    }

    public static String getQuestionCategoryMapKey(String position, String interviewRecordTypeName)
    {
        return position + '|' + interviewRecordTypeName;
    }
    
    //return position specific question category for interviewRecordTypeName if it exists
    //otherwise return default
    public static String getQuestionCategory(String position, String interviewRecordTypeName)
    {
        Map<String, InterviewQuestionCategoryMap__c> questionCategoryMap = 
            InterviewQuestionCategoryMap__c.getAll();
        if (questionCategoryMap != null)
        {
            InterviewQuestionCategoryMap__c positionSpecificValue = 
                questionCategoryMap.get(getQuestionCategoryMapKey(position, interviewRecordTypeName));
            if (positionSpecificValue != null)
            {
                return positionSpecificValue.Question_Category__c;
            } 
            else
            {
                InterviewQuestionCategoryMap__c defaultValue = 
                    questionCategoryMap.get(getQuestionCategoryMapKey(DEFAULT_POSITION, interviewRecordTypeName));
                if (defaultValue != null)
                {
                    return defaultValue.Question_Category__c;
                }
            }
        }
        return ''; // system misconfigured - consider throwing exception
    }
    
    public static List<Interview_Question__c> GetActiveQuestions(String position, String interviewRecordTypeName)
    {
        List<Interview_Question__c> interviewQuestions = 
            [select Id
             from   Interview_Question__c
             where  Question_Category__c =: getQuestionCategory(position, interviewRecordTypeName)
             and    Active__c = true 
             order by Sort_Order__c, Domain__c nulls last];
        
        return interviewQuestions;
    }
}