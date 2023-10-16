public class CTARatingExtnController 
{
    public class CTADetailedRating
    {
        public string scoreString
        {
            get
            {
                if(ratings.Score__c != null)
                {
                    return (ratings.Score__c > 3 ? 4 : ratings.Score__c).format();
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
                    ratings.Score__c = integer.valueOf(value);
                }
            }
        }
        public CTA_Review_Ratings__c ratings { get; set; }

        public CTADetailedRating(CTA_Review_Ratings__c rr)
        {
            ratings = rr;
        }
    }

    transient private CTA_Review_Session__c scoresObject;
    public CTA_Review_Session__c ReviewScores
    {
        get
        {
            if(scoresObject == null)
            {
                scoresObject = [select  Total_Score_Related_List__c, Grade_Icon__c,
                                        Architecture_Total__c, Architecture_Grade_Icon__c,
                                        Security_Total__c, Security_Grade_Icon__c,
                                        Integration_Total__c, Integration_Grade_Icon__c,
                                        Solution_Total__c, Solution_Grade_Icon__c,
                                        Communication_Total__c, Communication_Grade_Icon__c,
                                        Dev_Lifecycle_Total__c, Dev_Lifecycle_Grade_Icon__c
                                from CTA_Review_Session__c where Id =: rSession.Id limit 1];
            }
            return scoresObject;
        }
    }

    public CTA_Review_Session__c rSession { get; set; }
    public List<CTADetailedRating> dRating { get; set; }
    public CTA_Review_Scoring__c ratingScores { get; private set; }
    public List<SelectOption> ratings
    {
        get
        {
            if(ratings == null)
            {
                ratings = new List<SelectOption>();
                ratings.add(new SelectOption(ratingScores.Rating1_Score_Value__c.format(), ratingScores.Rating1_Score_Label__c));
                ratings.add(new SelectOption(ratingScores.Rating2_Score_Value__c.format(), ratingScores.Rating2_Score_Label__c));
                ratings.add(new SelectOption(ratingScores.Rating3_Score_Value__c.format(), ratingScores.Rating3_Score_Label__c));
                ratings.add(new SelectOption(ratingScores.Rating4_Score_Value__c.format(), ratingScores.Rating4_Score_Label__c));
            }
            return ratings;
        }
        set;
    }
    private ApexPages.StandardController stdCtrl;
    
    public CTARatingExtnController(ApexPages.StandardController stdCtrl)
    {
        if (!Test.isRunningTest())
        {
            this.stdCtrl = stdCtrl;
        }
        
        ratingScores = CTA_Review_Scoring__c.getOrgDefaults();

        rSession = (CTA_Review_Session__c) stdCtrl.getRecord();
        if(dRating == null)
        {
            dRating = new List<CTADetailedRating>();
            for(CTA_Review_Ratings__c rr: [select id, Comments__c, Score__c, 
                                                       CTA_Ratings_Criteria__r.Category__c, 
                                                       CTA_Ratings_Criteria__r.Criteria__c, CTA_Ratings_Criteria__r.Review_Type__c,
                                                       CTA_Ratings_Criteria__r.Rating1_Definition__c, CTA_Ratings_Criteria__r.Rating2_Definition__c,
                                                       CTA_Ratings_Criteria__r.Rating3_Definition__c, CTA_Ratings_Criteria__r.Rating4_Definition__c
                                                       from CTA_Review_Ratings__c
                                                       where CTA_Review_Session__c = :rSession.id
                                                       order by CTA_Ratings_Criteria__r.Sort_Order__c, CTA_Ratings_Criteria__r.Category__c nulls last])
            {
                dRating.add(new CTADetailedRating(rr));
            }
        }
    }

    public string reviewType
    {
        get
        {
            if(reviewType == null)
            {
                reviewType = Util.GetRecordTypes('CTA_Review_Session__c').get(rSession.RecordTypeId).DeveloperName;
            }
            return reviewType;
        }
        set;
    }
    
    public PageReference sendResults()
    {
        rSession.Send_Results__c = true;
        try
        {
            doSave();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Results sent to candidate'));
            System.Debug ('URL =' + URL.getSalesforceBaseURL().toExternalForm() + '/' + rSession.id);
            
            PageReference returnPage = new PageReference(URL.getSalesforceBaseURL().toExternalForm() + '/' + rSession.id); 
            returnPage.setRedirect(true);
            return returnPage;
        }
        catch (Exception e) 
        {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference saveScores()
    {
        
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
        
    private void doSave() 
    {
        List<CTA_Review_Ratings__c> evals = new List<CTA_Review_Ratings__c>();
        for(CTADetailedRating dr: dRating)
        {
            evals.add(dr.ratings);
        }
        update evals;
        update rSession;
    }
    
}