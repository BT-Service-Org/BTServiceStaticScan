trigger UserCompetenciesTrigger on UserCompetencies__c (before insert,before update) {
    if(Trigger.isBefore && trigger.isInsert){
        UserCompetenciesTriggerHandler.userLevelUpdate(Trigger.New,null);
    }
    else if(Trigger.isBefore && trigger.isUpdate){
        UserCompetenciesTriggerHandler.userLevelUpdate(Trigger.New,Trigger.oldMap);
    }
}