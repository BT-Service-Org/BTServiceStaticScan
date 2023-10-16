/****************************
* Created By - Mahesh, Gunolla
* Purpose - This is a Schedule batch class for GDC_DA_OB_ReminderNotifyIndMetrics_Batch
****************************/
global class GDC_DA_SD_ReminderScheduler  implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GDC_DA_OB_ReminderNotifyIndMetrics_Batch batch = new GDC_DA_OB_ReminderNotifyIndMetrics_Batch();
        Database.executebatch(batch);
    }
}