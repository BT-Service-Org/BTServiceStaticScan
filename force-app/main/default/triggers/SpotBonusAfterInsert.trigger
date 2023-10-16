trigger SpotBonusAfterInsert on Spot_Bonus__c (after insert) 
{
    List<PA_Customer_Survey__c> custSurveys = new List<PA_Customer_Survey__c>();
    // Making assumption that you won't have multiple spot bonus records for a single contact in a single trigger
    for(Spot_Bonus__c sp: trigger.new)
    {
        //System.debug('Spot Bonus Id: ' + sp.Id);
        Id contactId = sp.Contact__c;
        //System.debug('Contact Id: ' + contactId);
        for(PA_Customer_Survey__c cs: [select Id from PA_Customer_Survey__c 
                                        where Contact__c =: contactId 
                                        and Spot_Bonus__c = null])
        {
            //System.debug('Customer Survey Id: ' + cs.Id);
            cs.Spot_Bonus__c = sp.Id;
            custSurveys.add(cs);
        }
    }

    update custSurveys;
}