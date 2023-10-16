/**
 * @author anurag.suman
 * @param insert 
 * @param update 
 * @description Trigger for Article_Tags__c object
 */
trigger ArticleTagsTrigger on Article_Tags__c (before insert, before update) {
    if(trigger.isbefore){
        ArticleTagsTriggerHandler.isUniqueRecord(trigger.new,trigger.oldmap);
    }
}