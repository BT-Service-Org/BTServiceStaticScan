global class PSCKnowledgeUAABatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        PSCKnowledgeUAABatch batch = new PSCKnowledgeUAABatch();
        Database.executebatch(batch);
    }
}