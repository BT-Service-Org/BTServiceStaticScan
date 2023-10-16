trigger GDC_DA_ProjectSetupTrigger on GDC_DA_Project_Setup__c(before insert,before update,after insert,after update) {
    //Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
        
    }
    //After Insert
    if(Trigger.isInsert && Trigger.isAfter){
    	GDC_DA_ProjectSetupTriggerHandler.createDefaultProjectMetrics(trigger.new,null);    
        GDC_DA_ProjectSetupTriggerHandler.activateTeamMembers(trigger.new,null);
    }
    //Before Update
    if(Trigger.isUpdate && Trigger.isBefore){
        GDC_DA_ProjectSetupValidations.handleProjectSetupValidations(trigger.oldMap,trigger.new);
    }
    //After update
    if(Trigger.isUpdate && Trigger.isAfter){
        GDC_DA_ProjectSetupTriggerHandler.createDefaultProjectMetrics(trigger.new,trigger.oldMap);  
    	GDC_DA_ProjectSetupValidations.handleMetricsChanges(trigger.oldMap,trigger.new);
        GDC_DA_ProjectSetupValidations.handleProjectCompletionMetricChanges(trigger.oldMap,trigger.new);
        GDC_DA_ProjectSetupValidations.handleGeoMemberChange(trigger.oldMap,trigger.new);
        GDC_DA_ProjectSetupTriggerHandler.activateTeamMembers(trigger.new,trigger.oldMap);
        GDC_DA_ProjectSetupTriggerHandler.deactivateTeamMembers(trigger.new,trigger.oldMap);
        GDC_DA_ProjectSetupTriggerHandler.createNewProjectMetrics(trigger.oldMap, trigger.new);       
    }
}