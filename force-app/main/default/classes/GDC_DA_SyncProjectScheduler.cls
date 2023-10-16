/****************************
* Created By - Shraddha Vashishtha
* Purpose - This is a Schedule batch class for GDC_DA_SyncProjectBatch
****************************/
global class GDC_DA_SyncProjectScheduler  implements Schedulable {
    global void execute(SchedulableContext ctx) {
    
    GDC_DA_SyncProjectBatch projBatch = new GDC_DA_SyncProjectBatch();
    database.executeBatch(projBatch, 200);
   }
}