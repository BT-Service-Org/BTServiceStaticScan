global class StationContentGroupingAssociationsUpdate implements Database.Batchable<sObject> {
    global String [] email = new String[] {'nmcdonald@salesforce.com'};
        
    global Database.QueryLocator start (Database.BatchableContext bc) {
        System.debug(LoggingLevel.Info,'batch start');
        String query = 'SELECT Id, Order__c, Station_Content__r.Id, Station_Content__r.Order__c FROM StationGroupingAssociation__c WHERE Order__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<sObject> scope) {
        System.debug(LoggingLevel.Info,'batch execute');
        List<StationGroupingAssociation__c> updated = new List<StationGroupingAssociation__c>();
        for (sObject obj : scope) {
            StationGroupingAssociation__c grouping = (StationGroupingAssociation__c)obj;
            grouping.Station_Content__r.Order__c = grouping.Order__c;
            updated.add(grouping);
            System.debug(LoggingLevel.Info,'updated: ' + obj.Id);
        }
        
        if (updated != null && updated.size() > 0) {
            System.debug(LoggingLevel.Info,'updating list of size ' + updated.size());
            Database.update(updated);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.Info,'batch finished');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        mail.setToAddresses(email);
        mail.setReplyTo('nmcdonald@salesforce.com');
        mail.setSenderDisplayName('Apex Batch Processing');
        mail.setSubject('Batch Processing ' + a.Status);
        mail.setPlainTextBody('The Batch Apex job processed ' + a.TotalJobItems + ' batches with '+a.NumberOfErrors + ' failures ' + 'Job Item processed are ' + a.JobItemsProcessed);
      	Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
    }
    
    global void execute(SchedulableContext sc) {
        StationContentGroupingAssociationsUpdate instance = new StationContentGroupingAssociationsUpdate();
        database.executeBatch(instance, 100);
    }
}