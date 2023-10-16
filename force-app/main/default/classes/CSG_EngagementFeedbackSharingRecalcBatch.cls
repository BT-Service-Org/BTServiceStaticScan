public class CSG_EngagementFeedbackSharingRecalcBatch implements Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // build query to get the users with hierarchy info, who have feedback records and have hierarchy changes.
        return Database.getQueryLocator(
            'SELECT ID, (Select Id from Shares where RowCause = \'Management_Hierarchy__c\') FROM CSG_Project_Feedback__c '
        );
    }
    public void execute(Database.BatchableContext bc, List<CSG_Project_Feedback__c> scope){
        
        List<CSG_Project_Feedback__c> listPrjFdbkToRecalc = new List<CSG_Project_Feedback__c>();
        List<CSG_Project_Feedback__Share> listCSGPrjFdbkShares_ToDelete = new List<CSG_Project_Feedback__Share>();
        // Get all the Feedback Records from Project Feedback Object to Purge the sharing and reinsert. 
        for(CSG_Project_Feedback__c prjFdbk : scope)
        {
            listCSGPrjFdbkShares_ToDelete.addAll(prjFdbk.Shares);
            listPrjFdbkToRecalc.add(prjFdbk);
        }
        delete listCSGPrjFdbkShares_ToDelete;
        
        CSG_PrjFdbkSharingTrigger_Handler.insertSharingRecord(listPrjFdbkToRecalc);
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed');
        AsyncApexJob job = [SELECT Id, Status, ExtendedStatus, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        System.debug('Job: ' + job);
        System.debug('recordsProcessed: ' + recordsProcessed);
        
        
        
        String htmlBody = '<div>Records Processed: ' + recordsProcessed + '</div>';
        htmlBody += '<div>Job ID: ' + bc.getJobId() + '</div>';
        htmlBody += '<div>Total Job Items: ' + job.TotalJobItems + '</div>';
        htmlBody += '<div> Number of Errors: ' + job.NumberOfErrors + '</div>';
        htmlBody += '<div> Extended Status: ' + job.ExtendedStatus + '</div>';
        
        String plainText = 'Records Processed: ' + recordsProcessed + '\n';
        plainText += 'Job ID: ' + bc.getJobId() + '\n';
        plainText += 'Total Job Items: ' + job.TotalJobItems + '\n';
        plainText += 'Number of Errors: ' + job.NumberOfErrors + '\n';
        plainText += 'Extended Status: ' + job.ExtendedStatus + '\n';
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Engagement Feedback Sharing Recalc Status: ' + job.Status);
        mail.setPlainTextBody(plainText);
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}