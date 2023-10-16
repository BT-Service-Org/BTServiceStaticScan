/****************************
* Created By - Mahesh, Gunolla
* Purpose - This is a batch class, used for querying GDC Metric records with Metric End Date is YESTERDAY and Update the 
* Metric Status and Notify Geo Lead. 
****************************/
public class GDC_DA_UpdateMetricStatusAndNotify_Batch implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Status__c, EndDate__c, ProjectName__r.Project_Owner__c, ProjectName__r.Project_Owner__r.Email from GDC_DA_Metric__c where EndDate__c < TODAY AND Status__c=\'Draft\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<GDC_DA_Metric__c> MetricsUpdateList = new List<GDC_DA_Metric__c>();
        List<GDC_DA_Metric_Line_Items__c> IndMetricsUpdateList = new List<GDC_DA_Metric_Line_Items__c>();
        system.debug('scope@@@ '+ scope);
        
        Set<Id> metricIds = new Set<Id>();
        for(GDC_DA_Metric__c metric : (List<GDC_DA_Metric__c>)scope){
        	metricIds.add(metric.Id);
            metric.Status__c = 'Submitted for Review';
            MetricsUpdateList.add(metric);
        }
        system.debug('MetricsUpdateList@@@ '+ MetricsUpdateList);
        
        List<GDC_DA_Metric_Line_Items__c> IndividualMetricsList = [Select Id, Status__c from GDC_DA_Metric_Line_Items__c  where GDC_DA_Metric__c IN:metricIds AND Status__c =:'Draft'];
        for(GDC_DA_Metric_Line_Items__c mli: IndividualMetricsList){
        	mli.Status__c = 'Entry Missed';
            IndMetricsUpdateList.add(mli);
        }
        system.debug('IndMetricsUpdateList@@@ '+ IndMetricsUpdateList);
        if(!IndMetricsUpdateList.isEmpty()){
        	update IndMetricsUpdateList;    
        }
        
        if(!MetricsUpdateList.isEmpty()){
        	update MetricsUpdateList;    
        }
        
        List<EmailTemplate> template = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName ='GDC_DA_Review_Email_to_Geo_Lead'];
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for(GDC_DA_Metric__c metric : (List<GDC_DA_Metric__c>)scope){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template[0].Id, metric.ProjectName__r.Project_Owner__c, metric.Id);
            String emailSubject = email.getSubject();
            String emailTextBody = email.getPlainTextBody();
            email.setTargetObjectId(metric.ProjectName__r.Project_Owner__c);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.setToAddresses(new List<String> {metric.ProjectName__r.Project_Owner__r.Email});
            /*if(!lstEmailAddress.isEmpty())
			email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);*/
            email.setTreatTargetObjectAsRecipient(false);
            emailsList.add(email);
            
        }
         system.debug('emailsList@@@ '+ emailsList);
        if(!emailsList.isEmpty() && !Test.isRunningTest()){
            Messaging.sendEmail(emailsList);
        }
       
    }
    public void finish(Database.BatchableContext BC){
        
    }
}