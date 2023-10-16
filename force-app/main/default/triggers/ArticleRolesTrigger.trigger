trigger ArticleRolesTrigger on Article_Roles__c (before insert, before update) {

    
    if(trigger.isbefore){
        ArticleRolesTriggerHandler.isUniqueRecord(trigger.new);
    }
}