trigger PSCUtilityTrigger on PSC_Utility__e (after insert) {
    if(Trigger.isAfter && trigger.isInsert){
            PSCUtilityTriggerHandler.performUtilityActions(Trigger.New);
    }
}