/**
 * 
 * @author anurag.suman
 * @group Services Central
 * @description This is controller for PSCMethodDetail component
 */
public with sharing class PSCMethodDetailCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getTableOfContentsValues(String key) {
        return PSCSettingService.getValue(key);
    }

    @AuraEnabled(Cacheable=true)
    public static String getMethodId(String key) {
        return PSCMethodCardService.getMethodId(key);
    }

    @AuraEnabled(Cacheable=true)
    public static List<Method_Outcome__c> getMethodOutcomes(String methodId) {
        return new List<Method_Outcome__c>([SELECT Id,Outcome__r.Title__c
                                            FROM Method_Outcome__c 
                                            WHERE Method__c = :methodId
                                            AND Outcome__c != NULL
                                            ORDER BY Order__c ASC NULLS LAST]);
    }
}