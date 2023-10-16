/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For triggering reminder notifications based on reminder number.
*/ 

public with sharing class PRJ180_ReminderNotificationsBatch implements Database.Batchable<sObject>,Database.Stateful {
    private static final String PRJ180_REMINDER_EMAIL_TEMPLATE = 'PRJ180_Feedback_Completion_Reminder_Email';
    private static final String PRJ180_ORG_WIDE_ADDRESS = 'project180feedback@salesforce.com';
    private static final String PRJ180_COMPLETE_FEEDBACK_STATUS = 'Completed';
    private static final String PRJ180_ABANDONED_FEEDBACK_STATUS = 'Abandoned';
    private static final String PRJ180_RECORD_TYPE_NAME = 'PRJ180_Engagement_Feedback';
    private static  Integer prj180_Reminder1_Days;
    private static  Integer prj180_Reminder2_Days;
    private static  Integer prj180_Reminder3_Days;
    private Date prj180_Reminder_CutOff_Date;
    private Date prj180_Reminder_CutOff_Date_Plus1;
    private List<String> lstClosedStatus = new List<String>{PRJ180_COMPLETE_FEEDBACK_STATUS, PRJ180_ABANDONED_FEEDBACK_STATUS};


    private List<OrgWideEmailAddress> orgWideAddress;
    private List<EmailTemplate> template;
    public PRJ180_ReminderNotificationsBatch (Integer ReminderNumber) {
        this.template = [SELECT ID, Name from EmailTemplate where DeveloperName = :PRJ180_REMINDER_EMAIL_TEMPLATE];
        this.orgWideAddress = [SELECT ID FROM OrgWideEmailAddress WHERE Address = :PRJ180_ORG_WIDE_ADDRESS];
        prj180_Reminder1_Days = (Integer)PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Reminder1__c;
        prj180_Reminder2_Days = (Integer)PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Reminder2__c;
        prj180_Reminder3_Days = (Integer)PRJ180_Feedback_Configuration__c.getOrgDefaults().PRJ180_Reminder3__c;
        if(ReminderNumber == 1) {
            prj180_Reminder_CutOff_Date = system.today() - prj180_Reminder1_Days; 
        }
        else if(ReminderNumber == 2) {
            prj180_Reminder_CutOff_Date = system.today() - prj180_Reminder2_Days;
        }
        else if(ReminderNumber == 3) {
            prj180_Reminder_CutOff_Date = system.today() - prj180_Reminder3_Days;
        }
        prj180_Reminder_CutOff_Date_Plus1 = prj180_Reminder_CutOff_Date+1;

    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String Query =  'SELECT ID, CSG_Feedback_Provider__c,PRJ180_Feedback_Provider_Email__c,PRJ180_Last_Reminder_Sent__c,PRJ180_Notification__c '+ 
                        'FROM CSG_Project_Feedback__c '+
            			'WHERE recordtype.developername = :PRJ180_RECORD_TYPE_NAME AND CSG_Feedback_Request_Status__c NOT IN :lstClosedStatus '+
            			'AND CREATEDDATE >= :prj180_Reminder_CutOff_Date AND CREATEDDATE < :prj180_Reminder_CutOff_Date_Plus1';
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext bc, List<CSG_Project_Feedback__c> scope) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<CSG_Project_Feedback__c> lstFeedbackToBeUpd = new List<CSG_Project_Feedback__c>();
        for(CSG_Project_Feedback__c c: scope){
            mailList.add(getFeedbackReminderEmail(template[0].Id, c.PRJ180_Feedback_Provider_Email__c , orgWideAddress[0].Id, c.CSG_Feedback_Provider__c, c.id));
        }
        if(!mailList.isEmpty()){
            Messaging.SendEmailResult[] sentEmailResultsList = sendEmail(mailList);
            List<Id> lstFailedIds = new List<Id> ();
            for(Messaging.SendEmailResult res: sentEmailResultsList){        
                if(!res.isSuccess()){
                List<Messaging.SendEmailError> errorList = res.getErrors();
                    if(errorList.size()>0){
                        lstFailedIds.add(errorList[0].getTargetObjectId());
                       // Logger.error(errorList[0].getMessage());           //Commented till QA gets nebula logger installed   
                       // Logger.error(errorList[0].getTargetObjectId());
                    }    
                }
             }
          //   Logger.saveLog();
            for(CSG_Project_Feedback__c c: scope) {
                if(!lstFailedIds.contains(c.id)){
                    c.PRJ180_Last_Reminder_Sent__c = system.now();
                    c.PRJ180_Notification__c = c.PRJ180_Notification__c == null ? 1 : c.PRJ180_Notification__c+1;
                    lstFeedbackToBeUpd.add(c);
                }    
            }
        }
        
        Database.SaveResult[] srList = Database.update(lstFeedbackToBeUpd, false);

/* Commented till QA org gets Nebula logger        
	// Iterate through each returned result
	for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
        // Operation failed, so get all errors                
        	for(Database.Error err : sr.getErrors()) {
                Logger.error(err.getMessage());  
             }
    	}
	}
    // Logger.saveLog();
*/    
    }

    public void finish(Database.BatchableContext bc) {

    }

    private static Messaging.SingleEmailMessage getFeedbackReminderEmail (Id emailTemplateId, string providerEmail, Id orgWideAddressId, Id FeedbackProviderId, id efId) {
        List<String> lstToEmailAddress = new List<String>();
        lstToEmailAddress.add(providerEmail);
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateId, FeedbackProviderId, efId);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(mail.getPlainTextBody());
        mail.setSubject(mail.getSubject());
        if(orgWideAddressId != null) {
            mail.setOrgWideEmailAddressId(orgWideAddressId);
        }
        mail.setToAddresses(lstToEmailAddress);
        return mail;
    }

    public static Messaging.SendEmailResult[] sendEmail(List<Messaging.SingleEmailMessage> messages) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
        return results;
    }
}