global class CTAReviewUtilities 
{
    private static List<CTA_Review_Ratings__c> reviewRatings;
    
    public static void CreateReviewRatings(List<CTA_Review_Session__c> ratings)
    {
        List<CTA_Ratings_Criteria__c> hypotheticalWithGovQuestions = null;
        List<CTA_Ratings_Criteria__c> hypotheticalWithoutGovQuestions = null;
        reviewRatings = new List<CTA_Review_Ratings__c>();
        Map<Id, RecordType> recordTypeMap = Util.GetRecordTypes('CTA_Review_Session__c');
        
        for(CTA_Review_Session__c session: ratings)
        {
            string recordTypeName = recordTypeMap.get(session.RecordTypeId).DeveloperName;
            if(recordTypeName == 'Hypothetical_Scenario_with_Governance')
            {
                if(hypotheticalWithGovQuestions == null)
                {
                    hypotheticalWithGovQuestions = CTARatingsCriteriaUtilities.GetActiveCriteria(CTARatingsCriteriaUtilities.SessionCategories.Hypothetical_Scenario_with_Governance);
                }
                CreateCriteriaPerSession(session, hypotheticalWithGovQuestions);
            }
            else if(recordTypeName == 'Hypothetical_Scenario_without_Governance')
            {
                if(hypotheticalWithoutGovQuestions == null)
                {
                    hypotheticalWithoutGovQuestions = CTARatingsCriteriaUtilities.GetActiveCriteria(CTARatingsCriteriaUtilities.SessionCategories.Hypothetical_Scenario_without_Governance);
                }
                CreateCriteriaPerSession(session, hypotheticalWithoutGovQuestions);
            }
        }
        
        if(reviewRatings.Size() > 0)
        {
            insert reviewRatings;
        }
    }
    
    private static void CreateCriteriaPerSession(CTA_Review_Session__c session, List<CTA_Ratings_Criteria__c> questions)
    {
        for(CTA_Ratings_Criteria__c question: questions)
        {
            CTA_Review_Ratings__c rr = new CTA_Review_Ratings__c
            (
                CTA_Review_Session__c = session.Id, 
                CTA_Ratings_Criteria__c = question.Id,
                Weight__c = question.weight__c,
                Category__c = question.Category__c
            );
            reviewRatings.add(rr);
        }
    }

}