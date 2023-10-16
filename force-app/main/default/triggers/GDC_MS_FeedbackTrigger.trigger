trigger GDC_MS_FeedbackTrigger on gdc_ms_Feedback__c (after insert, after update, after delete, after undelete) {
    
    if(trigger.isInsert || trigger.isUndelete){
        GDC_MS_FeedbackTriggerHandler.afterInsert(Trigger.new);
    }
    if(trigger.isUpdate || trigger.isDelete){
        GDC_MS_FeedbackTriggerHandler.afterUpdate(Trigger.old);
    }
    
    
}