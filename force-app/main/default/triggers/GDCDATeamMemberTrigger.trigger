trigger GDCDATeamMemberTrigger on GDC_DA_Team_Member__c (After Insert, Before Update) {
    if(Trigger.isInsert && Trigger.isAfter){
        GDCDATeamMemberTriggerHandler.createIndividualMetricItems(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        GDCDATeamMemberTriggerHandler.deleteIndividualMetricItems(trigger.new , trigger.oldMap);
        GDCDATeamMemberTriggerHandler.addIndividualMetricItems(trigger.new , trigger.oldMap);
    }
}