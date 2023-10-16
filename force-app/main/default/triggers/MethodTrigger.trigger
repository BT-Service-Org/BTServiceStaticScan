trigger MethodTrigger on Method__c (before insert, after update, before update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        MethodTriggerController.fieldTracking(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        //MethodTriggerController.addParentMethod(Trigger.New);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        MethodTriggerController.shareRecord(Trigger.new, Trigger.oldMap);
    }   
}