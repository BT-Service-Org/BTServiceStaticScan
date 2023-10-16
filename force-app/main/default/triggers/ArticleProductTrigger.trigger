/**
 * @author anurag.suman
 * @param insert 
 * @param update 
 * @description Trigger for Article_Product__c object
 */
trigger ArticleProductTrigger on Article_Product__c (before insert, before update) {

    
    if(trigger.isbefore){
        ArticleProductTriggerHandler.isUniqueRecord(trigger.new,trigger.oldMap);
    }
}