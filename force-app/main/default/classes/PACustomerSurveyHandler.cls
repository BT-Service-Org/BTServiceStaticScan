/*Helper Class for PA_Customer_Survey__C Trigger*/
public class PACustomerSurveyHandler {
    
/* The method add PA_ONboarding Id on the Customer Survey record* Created on 5/23/2016 by Anu for Wave Dashboards*/
    
    public static void FillPAOnboardingID (List<PA_Customer_Survey__c> CustSurveys)
    {
        
        List<Contact> ConPAs = new List<Contact>();
        Map<Id,Id> SurveyConMap = new Map<Id,Id> ();
        Map<Id,PA_Onboarding__c> ConMap = new Map <Id,PA_Onboarding__c> ();
            
        for (PA_Customer_Survey__c a : CustSurveys)
        {
            SurveyConMap.put(a.Contact__c, a.Id);
        }
        
        ConPAs = [select Id, (select Id from PA_Onboarding__r limit 1) from Contact where Id in :SurveyConMap.keySet()];
        System.Debug ('Contact found...' + ConPAs);
        
        for (Contact Con : ConPAs)
        {
            System.Debug ('PA Onboarding...' + Con.PA_Onboarding__r);
            if (!(Con.PA_Onboarding__r.isempty()))
            {
            	ConMap.put(Con.Id, Con.PA_Onboarding__r);
            }
        }
        
        for (PA_Customer_Survey__c b: CustSurveys)
        {
            if (ConMap.get(b.Contact__c) != null)
            {
             	b.PA_Onboarding__c = ConMap.get(b.Contact__c).Id;
            }

        }
        
    }

}