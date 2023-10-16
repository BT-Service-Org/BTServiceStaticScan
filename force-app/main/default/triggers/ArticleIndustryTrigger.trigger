/**
 * @author anurag.suman
 * @param insert 
 * @param update 
 * @description Trigger for Article_Industry__c object
 */
trigger ArticleIndustryTrigger on Article_Industry__c (before insert, before update) {
    if(trigger.isbefore){
        ArticleIndustryTriggerHandler.isUniqueRecord(trigger.new,trigger.oldMap);
    }
}