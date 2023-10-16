trigger EDHQ_MethodForEngagementTrigger on Methods__c (after update) {

    if(trigger.isAfter == true && trigger.isUpdate ==true){
        EDHQ_MethodForEngagementTriggerHandler.publishPlatformEvent(trigger.new, trigger.oldmap);
    }
    
}