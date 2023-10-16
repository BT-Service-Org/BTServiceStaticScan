/****************************
* Created By - Mahesh, Gunolla
* Purpose - This is a Schedule batch class for GDC_DA_UpdateMetricStatusAndNotify_Batch
****************************/
global class GDC_DA_UpdateMetricStatusNotifySchedular implements Schedulable {
    global void execute(SchedulableContext ctx) {
    	GDC_DA_UpdateMetricStatusAndNotify_Batch batch = new GDC_DA_UpdateMetricStatusAndNotify_Batch();
        Database.executebatch(batch);
    }
}