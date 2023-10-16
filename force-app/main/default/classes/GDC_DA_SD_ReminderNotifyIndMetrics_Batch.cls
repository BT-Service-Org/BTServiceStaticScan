/****************************
* Created By - Mahesh, Gunolla
* Purpose - This is a batch class, used for Sending the reminder Notifications Same day on Metric End Date 
* to individual Team Member. 
****************************/
public class GDC_DA_SD_ReminderNotifyIndMetrics_Batch  implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Status__c, Email__c,Project__c,GDC_DA_Metric__r.ProjectName__r.Project_Owner__c,GDC_DA_Metric__r.ProjectName__r.Project_Owner__r.Email, End_Date__c from GDC_DA_Metric_Line_Items__c where End_Date__c = TODAY AND Status__c=\'Draft\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    	List<EmailTemplate> template = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName ='GDC_DA_Final_Reminder_Email_for_Metric_Submission'];
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        
        List<String> sendTo = new List<String>();
        if(System.Label.GDC_DA_Emails_List.contains(';')){
        	sendTo.addAll((System.Label.GDC_DA_Emails_List).split(';'));    
        }
        else{
        	sendTo.add(System.Label.GDC_DA_Emails_List);        
        }
        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'gdcda@salesforce.com' Limit 1];

        for(GDC_DA_Metric_Line_Items__c metric : (List<GDC_DA_Metric_Line_Items__c>)scope){
            List<String> emailAddressList = new List<String> {metric.GDC_DA_Metric__r.ProjectName__r.Project_Owner__r.Email,metric.Email__c};
            emailAddressList.addAll(sendTo);
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template[0].Id, metric.GDC_DA_Metric__r.ProjectName__r.Project_Owner__c, metric.Id);
         	String emailSubject = email.getSubject();
            String emailTextBody = email.getHTMLBody();
             //Set Org Wide Email Address Id
             email.setOrgWideEmailAddressId(orgWideEmailAddress.Id); 
            email.setTargetObjectId(metric.GDC_DA_Metric__r.ProjectName__r.Project_Owner__c);
            email.setSubject(emailSubject);
            email.setHtmlBody(emailTextBody);
            //email.setToAddresses(new List<String> {metric.GDC_DA_Metric__r.ProjectName__r.Project_Owner__r.Email,metric.Email__c});
            email.setToAddresses(emailAddressList);
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