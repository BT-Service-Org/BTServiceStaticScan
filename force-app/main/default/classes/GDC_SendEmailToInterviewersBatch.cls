public class GDC_SendEmailToInterviewersBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    private static final String GDC_INTERVIEWER_PERMISSION_SET = 'GDC_Interviewer';
    private static final String GDC_INDIVIDUAL_EMAIL_TEMPLATE = 'GDC_Interviewer_Biweekly_Reminder_Email';
    private static final String GDC_MANAGER_EMAIL_TEMPLATE = 'GDC_Interviewer_Biweekly_Reminder_Email_With_Manager';
    private static final String GDC_ORG_WIDE_ADDRESS = 'gdc-hiring@salesforce.com';
    private static final String GDC_INTERVIEWER_SLOT_RECTYPE_DEVELOPER_NAME = 'GDC_Interview_Slot';
    private static final String AVAILABLE_SLOT_STATUS = 'Available';
    private static final String BOOKED_SLOT_STATUS = 'Booked';
    private static final Integer MINIMUM_SLOTS = Integer.valueOf(Label.GDC_Minimum_Interview_Slots);
    private static final Integer MINIMUM_SLOTS_NO_ESCALATION = Integer.valueOf(Label.GDC_Minimum_Interview_Slots_No_Escalation);

    private List<EmailTemplate> template;
    private boolean includeManager = false;
    private String batchQuery;
    private List<OrgWideEmailAddress> orgWideAddress;

    public GDC_SendEmailToInterviewersBatch(Boolean includeManager, String query) {
        this.includeManager = includeManager;
        this.orgWideAddress = [SELECT ID FROM OrgWideEmailAddress WHERE Address =: GDC_ORG_WIDE_ADDRESS];
        if(includeManager) {
            template = [SELECT ID, Name from EmailTemplate where DeveloperName =: GDC_MANAGER_EMAIL_TEMPLATE];
        }else  {
            template = [SELECT ID, Name from EmailTemplate where DeveloperName =: GDC_INDIVIDUAL_EMAIL_TEMPLATE];
        }
        if(query==null){
            String tmpQry = 'select id, FirstName, User_Record__c, User_Record__r.Email, Email, GDC_Hiring_Manager__c,GDC_Hiring_Manager__r.User_Record__c, GDC_Hiring_Manager__r.Email, GDC_Dont_Send_Escalation__c, (SELECT Id from Events where RecordType.DeveloperName =: GDC_INTERVIEWER_SLOT_RECTYPE_DEVELOPER_NAME and GDC_Slot_Status__c in (:AVAILABLE_SLOT_STATUS, :BOOKED_SLOT_STATUS) AND StartDateTime = NEXT_MONTH) from Contact Where User_Record__c in: userIds';
            this.batchQuery = this.includeManager?(tmpQry+' and GDC_Hiring_Manager__c != null and GDC_Dont_Send_Escalation__c = false'):tmpQry;
        }else{
            this.batchQuery = query;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<PermissionSetAssignment> psAssignments = [select PermissionSet.Name, AssigneeId from PermissionSetAssignment where PermissionSet.Name  =: GDC_INTERVIEWER_PERMISSION_SET];
        Set<Id> userIds = new Set<Id>();
        for(PermissionSetAssignment psa: psAssignments) {
            userIds.add(psa.AssigneeId);
        }
        return Database.getQueryLocator(this.batchQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope){ 
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Map<Id, List<String>> userIdSetByManagerId = new Map<Id, List<String>>();
        if(!template.isEmpty()) {
            for(Contact c: scope) {
                if(c.Events == null || (!c.GDC_Dont_Send_Escalation__c && c.Events.size() < MINIMUM_SLOTS) || (c.GDC_Dont_Send_Escalation__c && c.Events.size() < MINIMUM_SLOTS_NO_ESCALATION)) { // make this configurable
                    if(!includeManager) {
                        mailList.add(getIndividualEmailMessage(template[0].Id, c.User_Record__c, c.Id, orgWideAddress));
                    } else {
                        if (userIdSetByManagerId.containsKey(c.GDC_Hiring_Manager__r.User_Record__c)) {
                            userIdSetByManagerId.get(c.GDC_Hiring_Manager__r.User_Record__c).add(c.User_Record__c);
                        }else {
                            userIdSetByManagerId.put(c.GDC_Hiring_Manager__r.User_Record__c, new List<String>{c.User_Record__c});
                        }
                    }
                }
            }
            if(!userIdSetByManagerId.isEmpty()) {
                for(Id managerUserId: userIdSetByManagerId.keySet()) {
                    System.debug(userIdSetByManagerId.get(managerUserId));
                    mailList.add(getEmailMessageIncludingManager(template[0].Id, managerUserId, orgWideAddress, userIdSetByManagerId.get(managerUserId)));
                }
            }
        }
        if(!mailList.isEmpty()) {
            sendEmail(mailList);
        }
    }

    public void finish(Database.BatchableContext bc){

    }

    private static Messaging.SingleEmailMessage getEmailMessageIncludingManager(Id emailTemplateId, Id managerId, List<OrgWideEmailAddress> orgWideAddress, List<String> interviewerUserIds) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateId, null, null);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(mail.getPlainTextBody());
        mail.setSubject(mail.getSubject());
        if(!orgWideAddress.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
        }
        mail.setToAddresses(interviewerUserIds);
        mail.setCcAddresses(new List<String>{managerId});
        return mail;
    }

    private static Messaging.SingleEmailMessage getIndividualEmailMessage(Id emailTemplateId, String whoId, String whatId, List<OrgWideEmailAddress> orgWideAddress) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateId, whoID, whatID);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(mail.getPlainTextBody());
        mail.setSubject(mail.getSubject());
        if(!orgWideAddress.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
        }
        mail.setTargetObjectId(whoId);
        return mail;
    }

    public static void sendEmail(List<Messaging.SingleEmailMessage> messages) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
    }
}