trigger ArticleMethodTrigger on Article_Method__c (before insert, before update) {

    
    if(trigger.isbefore){
        ArticleMethodTriggerHandler.isUniqueRecord(trigger.new);
    }
}