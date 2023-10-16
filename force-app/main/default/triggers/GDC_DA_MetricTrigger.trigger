trigger GDC_DA_MetricTrigger on GDC_DA_Metric__c (before update,after update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
           // GDC_DA_MetricTriggerHandler.checkTeamMemberAccessInProject(Trigger.oldMap,Trigger.newMap);
        }
    }
    if(Trigger.isAfter)
    {
        if (Trigger.isUpdate) {
            //GDC_DA_MetricTriggerHandler.sendingMail(Trigger.oldMap,Trigger.newMap);
            GDC_DA_MetricTriggerHandler.updateProjectStatus(Trigger.oldMap,Trigger.newMap);
        }
    }
}