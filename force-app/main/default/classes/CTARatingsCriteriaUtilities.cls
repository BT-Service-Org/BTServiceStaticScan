global class CTARatingsCriteriaUtilities 
{
    public enum SessionCategories { Hypothetical_Scenario_with_Governance, Hypothetical_Scenario_without_Governance }
    
    static webservice string RenumberCriteria(string sessionCategory)
    {
        string resultStr = '';
        List<CTA_Ratings_Criteria__c> renumberedCriteria = new List<CTA_Ratings_Criteria__c>();
        integer i = 1;
        for(CTA_Ratings_Criteria__c rc: [select Id, weight__c, Category__c from CTA_Ratings_Criteria__c where Review_Type__c =: sessionCategory and Active__c = true
                                       order by Sort_Order__c, Category__c, LastModifiedDate desc nulls last])
        {
            rc.Sort_Order__c = i;
            renumberedCriteria.add(rc);
            i++;
        }
        
        if(renumberedCriteria.size() > 0)
        {
            try
            {
                update renumberedCriteria;
                resultStr = sessionCategory + ' Renumbered';
            }
            catch(Exception ex)
            {
                resultStr = ex.getMessage();
            }
        }
        else
        {
            resultStr = 'No evaluations to renumber';
        }
        
        return resultStr;
    }
    
    public static List<CTA_Ratings_Criteria__c> GetActiveCriteria(SessionCategories sc)
    {
        List<CTA_Ratings_Criteria__c> ratingCriteria = new List<CTA_Ratings_Criteria__c>();
        string strSC = '';
        
        if(sc == SessionCategories.Hypothetical_Scenario_with_Governance)
        {
        ratingCriteria = [select Id, weight__c, Category__c
                          from   CTA_Ratings_Criteria__c
                          where  Review_Type__c in ('Hypothetical', 'Governance')
                          and    Active__c = true 
                          order by Sort_Order__c, Category__c nulls last];    
        }
        else if(sc == SessionCategories.Hypothetical_Scenario_without_Governance)
        {
        ratingCriteria = [select Id, weight__c, Category__c
                          from   CTA_Ratings_Criteria__c
                          where  Review_Type__c = 'Hypothetical'
                          and    Active__c = true 
                          order by Sort_Order__c, Category__c nulls last];
       }
                
        return ratingCriteria;
    }
}