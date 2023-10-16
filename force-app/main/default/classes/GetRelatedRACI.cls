/**
 * @description       : Gets related RACI records associated to a specific Engagement Activity
 * @author            : Charles Gallagher
 * @last modified on  : 05-05-2021
 * @last modified by  : Charles Gallagher
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   05-05-2021   Charles Gallagher  Initial Version
**/
public class GetRelatedRACI 
{

    
    @AuraEnabled(cacheable=true)
    public static List<Enablement_RACI__c> getEnablementRACI(Id enablementActivityId)
    {
        List<Enablement_RACI__c> listToReturn = [Select Id, RACI__c, Name, Stakeholder_Role__r.Name, Stakeholder_Name__r.Name  
                                            FROM Enablement_RACI__c  
                                            Where Enablement_Activity__c  =: enablementActivityId];

        return listToReturn;
    }

}