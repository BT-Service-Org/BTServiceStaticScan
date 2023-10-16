trigger AssetIndustryTrigger on Asset_Industry__c (before insert, before update) {
    if(trigger.isbefore){
        AssetIndustryTriggerHandler.isUniqueRecord(trigger.new,trigger.oldMap);
    }
}