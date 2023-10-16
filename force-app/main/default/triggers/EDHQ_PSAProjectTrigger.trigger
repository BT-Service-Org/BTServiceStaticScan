trigger EDHQ_PSAProjectTrigger on PSA_Project__c (after update) {

    if(trigger.isAfter ==true && trigger.isUpdate ==true){
        EDHQ_PSAProjectTriggerHandler.publishPlatformEvent(trigger.new, trigger.oldmap,'SETUP');
    }
    
}