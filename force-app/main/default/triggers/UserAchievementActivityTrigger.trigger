trigger UserAchievementActivityTrigger on User_Achievement_Activity__c (before insert,before update, after insert, after update,after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        UserAchievementActivityTriggerHandler.updateUserCompetency(Trigger.New,null);
    }
    else if(Trigger.isAfter && Trigger.isUpdate){
        UserAchievementActivityTriggerHandler.updateUserCompetency(Trigger.New,Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete){
        UserAchievementActivityTriggerHandler.updateUserCompetency(Trigger.Old,null);
    }
    else if(Trigger.isbefore && Trigger.isInsert){
        UserAchievementActivityTriggerHandler.preventDuplicate(Trigger.New);//GKC-1019
    }
    else if(Trigger.isbefore && Trigger.isUpdate){
        UserAchievementActivityTriggerHandler.preventDuplicate(Trigger.New, Trigger.oldMap);//GKC-1019
    }
}