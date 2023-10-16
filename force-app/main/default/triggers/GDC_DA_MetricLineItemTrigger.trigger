trigger GDC_DA_MetricLineItemTrigger on GDC_DA_Metric_Line_Items__c (before update, after update) {
    if(Trigger.isBefore)
    {
        if (Trigger.isUpdate) {
            GDC_DA_MetricLineItemTriggerHandler.updateStatus(Trigger.oldMap,Trigger.newMap);
        }
    }
	if(Trigger.isAfter)
    {
        if (Trigger.isUpdate) {
            GDC_DA_MetricLineItemTriggerHandler.updateParentMetrics(Trigger.oldMap,Trigger.newMap);
        }
    }
}