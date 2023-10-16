trigger CSGProjectFeebackSharingTrigger on CSG_Project_Feedback__c (after insert) {
    if(trigger.isInsert){
        CSG_ProjectFeedbackSharingTriggerHandler.createFeedbackSharingRecords(trigger.new, true);
    }
}