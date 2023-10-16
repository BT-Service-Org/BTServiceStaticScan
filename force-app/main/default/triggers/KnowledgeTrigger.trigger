trigger KnowledgeTrigger on Knowledge__kav (before update) {
    if(Trigger.isUpdate && Trigger.isBefore){
        KnowledgeTriggerHandler.validateIsReviewed(Trigger.new,Trigger.oldMap);
    }
}