public with sharing class customMethodCreationController {
    public customMethodCreationController() {}

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(String recordTypeId) {
        return [SELECT Id,  Name FROM RecordType WHERE SobjectType = 'Method__c' AND ID= :recordTypeId]?.Name;
    }

    @AuraEnabled(cacheable=true)
    public static String getkeyPrefix() {
        Schema.DescribeSObjectResult r = Method__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }
}