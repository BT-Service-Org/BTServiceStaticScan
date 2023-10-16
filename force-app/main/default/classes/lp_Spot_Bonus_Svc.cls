public class lp_Spot_Bonus_Svc {

    public static void CalculateSpotBonus(List<String> contactEmails)
    {
        Map<ID, Contact> contactMap = new Map<ID, Contact>([SELECT Id, Email, FirstName, LastName, Certified_Technical_Architect__c   
                                                            FROM Contact 
                                                            WHERE Email IN :contactEmails 												
        												  ]);
        Integer currentFiscalYear = 0;
        
        if (System.Date.today().month() == 1)
            currentFiscalYear = System.Date.today().year() -1;
        else
            currentFiscalYear = System.Date.today().year();
        
        List<Spot_Bonus__c> spotBonusRecords = [SELECT Id, Name, Period_Start_Date__c,Is_Current__c,
                                                     Period_End_Date__c, Contact__c
                                                     FROM Spot_Bonus__c
                                                     WHERE Is_Current__c = true
                                                     AND Contact__c IN :contactMap.keySet()];
        
        List <Spot_Bonus__c> spotBonusRecordsToUpsert;
        List <PA_Customer_Survey__c> customerSurveysToUpsert;
        Map <String, List<PA_Customer_Survey__c>> mapProjectCSATs = new Map<String, List<PA_Customer_Survey__c>> ();
        
        
         AggregateResult[] csatResults = [SELECT AVG(Overall_Score__c) AvgScore , COUNT(Id) SurveyCount, 
                                          Contact__c, Account_Id__c
            							  FROM PA_Customer_Survey__c
                                          WHERE Contact__c IN :contactMap.keySet()
                                          AND Project_Duration__c > 273
                                          AND (Spot_Bonus__r.Fiscal_Year__c = :currentFiscalYear OR Spot_Bonus__c = null) 
                                          GROUP BY Contact__c, Account_Id__c
                                          ORDER BY Account_Id__c, Contact__c]; 
        
        for(AggregateResult csatResult: csatResults)
        {
            //for the project id specified find the current spot bonus record from spot bonus record list queried
            //earlier
            Spot_Bonus__c foundSpotBonusRecord = null;
            Integer avgScore = Integer.valueOf(csatResult.get('AvgScore'));
            Integer surveyCount = Integer.valueOf(csatResult.get('SurveyCount'));
            Integer surveyCountThreshold = 3;
            
            List<PA_Onboarding_Property__c> properties= (List<PA_Onboarding_Property__c>)[SELECT Key__c, Value__c from PA_Onboarding_Property__c where Key__c = 'SurveyCount'];
            if(!properties.isEmpty())
                surveyCountThreshold = Integer.valueOf(properties.get(0).Value__c); 
            
            System.debug('CalculateSpotBonus: avgScore = ' + String.valueOf(avgScore));
            System.debug('CalculateSpotBonus: surveyCount = ' + String.valueOf(surveyCount));
            System.debug('CalculateSpotBonus: surveyCountThreshold = ' + String.valueOf(surveyCountThreshold));
            
            if ( surveyCount >= surveyCountThreshold)
            {
            	String accountId = String.valueOf(csatResult.get('Account_Id__c'));
                Boolean isCTA = false;
                Id contactId = String.valueOf(csatResult.get('Contact__c'));
                Contact c = contactMap.get(contactId);
                if (c != null)
                {
                    if (c.Certified_Technical_Architect__c != null)
                        isCTA = true;
                }
                
                for(Spot_Bonus__c spotBonusRecord: spotBonusRecords)
                {
                    if(spotBonusRecord.Account_Id__c == accountId)
                    {
                        foundSpotBonusRecord = spotBonusRecord;
                        break;
                    }
                }    
                
                if (foundSpotBonusRecord == null)
                {
                    foundSpotBonusRecord = new Spot_Bonus__c();
                    foundSpotBonusRecord.Contact__c = String.valueOf(csatResult.get('Contact__c'));
                    foundSpotBonusRecord.Account_Id__c  = accountId;
                    foundSpotBonusRecord.Is_Current__c = true;
                    foundSpotBonusRecord.Fiscal_Year__c = currentFiscalYear;		
                }
                
                if (avgScore >= 8.5)
                {
                	if(isCTA)
                    	foundSpotBonusRecord.Expected_Bonus_Amount__c  = 25000;
                	else
                		foundSpotBonusRecord.Expected_Bonus_Amount__c  = 15000;
                }
                
                if(surveyCount == 4 && avgScore >= 8.5)
                {
                    if(isCTA)
                    	foundSpotBonusRecord.Actual_Bonus_Amount__c = 25000;
                    else
                        foundSpotBonusRecord.Actual_Bonus_Amount__c = 15000;
                    foundSpotBonusRecord.Is_Current__c = false;
                }
                if (spotBonusRecordsToUpsert == null)
                    spotBonusRecordsToUpsert = new List<Spot_Bonus__c>();
                
                spotBonusRecordsToUpsert.add(foundSpotBonusRecord);
            }    
        }
        System.debug('CalculateSpotBonus: spotBonusRecordsToUpsert ' + spotBonusRecordsToUpsert);
        if (spotBonusRecordsToUpsert != null)
        	UPSERT spotBonusRecordsToUpsert;
        
    }	
}