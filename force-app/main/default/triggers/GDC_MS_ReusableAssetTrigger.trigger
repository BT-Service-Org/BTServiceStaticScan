trigger GDC_MS_ReusableAssetTrigger on gdc_ms_ReusableAsset__c (before update) {
    
    for(gdc_ms_ReusableAsset__c updatedAsset : trigger.new){
        System.debug('condition '+GDC_MS_ReminderNotifyToAssetDeveloper.statusToBeIgnored.contains(updatedAsset.gdc_ms_Status__c));
        if(updatedAsset.gdc_ms_Status__c != trigger.oldMap.get(updatedAsset.Id).gdc_ms_Status__c && !GDC_MS_ReminderNotifyToAssetDeveloper.statusToBeIgnored.contains(updatedAsset.gdc_ms_Status__c)){
            updatedAsset.GDC_MS_Next_Reminder_Trigger_date__c = Date.today().addDays(7);
            updatedAsset.GDC_MS_Number_of_Reminder__c = 0;
        }
    }
}