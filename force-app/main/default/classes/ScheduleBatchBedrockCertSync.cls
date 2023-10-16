global class ScheduleBatchBedrockCertSync implements Schedulable {
    global void execute(SchedulableContext ctx) { 
        Id batchJobId = Database.executeBatch(new BatchBedrockSyncCert2LearningDomain(), 200);
        System.Debug('Job ID: ' + batchJobId); 
    }
}