global class PSCRewardLoginActivityScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        PSCRewardLoginActivityBatch batch = new PSCRewardLoginActivityBatch();
        Database.executebatch(batch);
    }
}