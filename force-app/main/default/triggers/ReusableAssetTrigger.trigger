trigger ReusableAssetTrigger on Reusable_Asset__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        ReusableAssetTriggerHandler.createUAATrackingRecord(Trigger.new, Trigger.oldMap);
        ReusableAssetTriggerHandler.addContributionTeam(Trigger.new, Trigger.oldMap);//SC-970
    }
}