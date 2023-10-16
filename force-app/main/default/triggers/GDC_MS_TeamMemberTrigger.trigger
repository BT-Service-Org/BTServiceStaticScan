trigger GDC_MS_TeamMemberTrigger on gdc_ms_TeamMember__c (before insert, before update) {

    /*if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            GDC_MS_TeamMemberTriggerHandler.updateTeamMember(Trigger.new);
        }
    }*/
    if(Trigger.isBefore){
        system.debug('in trigger team member');
        if(Trigger.isInsert || Trigger.isUpdate){
            GDC_MS_TeamMemberTriggerHandler.checkTeamMemberStatus(Trigger.newMap,Trigger.new);
        }

        if (Trigger.isUpdate) {
            GDC_MS_TeamMemberTriggerHandler.updateLastbioUpdatedDate(Trigger.newMap,Trigger.oldMap);
        }
    }

}