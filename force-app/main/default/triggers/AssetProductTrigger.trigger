trigger AssetProductTrigger on Asset_Product__c (before insert, before update) {
    if(trigger.isbefore){
        AssetProductTriggerHandler.isUniqueRecord(trigger.new,trigger.oldmap);
    }
}