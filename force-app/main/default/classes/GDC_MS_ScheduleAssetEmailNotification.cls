global class GDC_MS_ScheduleAssetEmailNotification implements Schedulable {
    global void execute(SchedulableContext SC){
        GDC_MS_ReminderNotifyToAssetDeveloper.notify();
    }
}