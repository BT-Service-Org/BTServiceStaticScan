global class GDC_DA_PSAssignBatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GDC_DA_PSAssignBatch batch = new GDC_DA_PSAssignBatch();
        Database.executebatch(batch);
    }
}