global with sharing class GDC_SendEmailToInterviewersScheduler implements Schedulable {
    private Boolean includeManager = false;
    global GDC_SendEmailToInterviewersScheduler(Boolean includeManager) {
        this.includeManager = includeManager;
    }
    global void execute(SchedulableContext sc) {        
        GDC_SendEmailToInterviewersBatch batch = new GDC_SendEmailToInterviewersBatch(includeManager, null);
        ID batchprocessid = Database.executeBatch(batch);
    }
}