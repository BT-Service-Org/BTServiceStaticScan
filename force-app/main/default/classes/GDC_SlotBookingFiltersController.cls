public without sharing class GDC_SlotBookingFiltersController {
    @AuraEnabled(Cacheable=true)
    public static UIPicklistWrapper getPicklistValuesForUi(){
        try {
            UIPicklistWrapper wrap = new UIPicklistWrapper();
            wrap.postingOptions = getPicklistValuesBasedOnFieldResult(Contact.GDC_Job_Posting__c.getDescribe());
            wrap.skillOptions = getPicklistValuesBasedOnFieldResult(Contact.GDC_Skill__c.getDescribe());
            List<Contact> hiringManagers = [Select id, Name from Contact where GDC_Is_Hiring_Manger__c = TRUE];
            List<PicklistValue> hiringManagerOptions = new List<PicklistValue>();
            for(Contact hm : hiringManagers) {
                hiringManagerOptions.add(new PicklistValue(hm.Name, hm.Id));
            }
            wrap.hiringManagerOptions = hiringManagerOptions;
            if(!wrap.hiringManagerOptions.isEmpty()) {
                List<Contact> interviewers = [Select id, Name from Contact where GDC_Job_Posting__c includes (:wrap.postingOptions[0].value) And GDC_Skill__c includes (:wrap.skillOptions[0].value) /*AND GDC_Hiring_Manager__c =: hiringManagerOptions[0].value*/];// Making Hiring Manger to Multi Select
                for(Contact i : interviewers) {
                    wrap.interviewerOptions.add(new PicklistValue(i.Name, i.id));
                }
            }
            return wrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<PicklistValue> getPicklistValuesBasedOnFieldResult(Schema.DescribeFieldResult fieldDescribe) {
        list<Schema.PicklistEntry> picklistData = fieldDescribe.getPickListValues();
        List<PicklistValue> transformedPicklistValues = new List<PicklistValue>();
        for(Schema.PicklistEntry pe: picklistData) {
            transformedPicklistValues.add(new PicklistValue(pe.getLabel(), pe.getValue()));
        }
        return transformedPicklistValues;
    }

    @AuraEnabled
    public static List<PicklistValue> getInterviewersBasedOnFilters(String stringifiedFilters){
        try {
            FiltersWrapper filters = (FiltersWrapper)JSON.deserialize(stringifiedFilters, FiltersWrapper.class);
            List<String> managers =  filters.hiringManager.split(';');
            List<PicklistValue> interviewerPicklistVals = new List<PicklistValue>();
            List<Contact> interviewers =  [SELECT ID, Name FROM Contact WHERE GDC_Job_Posting__c includes (:filters.jobPosting) And GDC_Skill__c includes (:filters.skill) AND GDC_Hiring_Manager__c IN :managers];
            for(Contact i : interviewers) {
                interviewerPicklistVals.add(new PicklistValue(i.Name, i.id));
            }
            return interviewerPicklistVals;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Event> getFutureHiringEvents() {
        return [Select id, ActivityDate, StartDateTime from Event where RecordType.DeveloperName = 'GDC_Interview_Slot' AND GDC_Slot_Type__c = 'Hiring Event' AND StartDateTime >= TODAY];
    }

    @AuraEnabled
    public static void createNewHiringEvent(Date evtDate){
        try {
            insert new Event(StartDateTime = evtDate, EndDateTime = evtDate, ActivityDate = evtDate, RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Type__c = 'Hiring Event');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteHiringEvents(List<Id> evtIds){
        try {
            delete[Select id from Event where id in: evtIds];
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class UIPicklistWrapper {
        @AuraEnabled public List<PicklistValue> postingOptions;
        @AuraEnabled public List<PicklistValue> hiringManagerOptions;
        @AuraEnabled public List<PicklistValue> skillOptions;
        @AuraEnabled public List<PicklistValue> interviewerOptions;
        public UIPicklistWrapper() {
            postingOptions = new List<PicklistValue>();
            hiringManagerOptions = new List<PicklistValue>();
            skillOptions = new List<PicklistValue>();
            interviewerOptions = new List<PicklistValue>();
        }
    }

    public class PicklistValue {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @InvocableMethod(label='Get Interviewer Emails')
    public static List<String> getInterviewersBasedOnFiltersForFlow(List<FiltersWrapper> filters){ 
        OrgWideEmailAddress orgWideAddress = [SELECT ID FROM OrgWideEmailAddress WHERE Address = 'gdc-hiring@salesforce.com' limit 1];
        EmailTemplate template;
        List<String> managers =  filters[0].hiringManager.split(';');
        List<String> managerUserIds = new List<String>();
        for(Contact manager: [Select Id, User_Record__c from Contact where id in :managers]){
            managerUserIds.add(manager.User_Record__c);
        }
        if(filters[0].identifier == 'Managers'){
            template = [SELECT ID, Name, Body from EmailTemplate where DeveloperName = 'GDC_Email_to_Manager_for_Emergency_Slot' limit 1];
            sendEmailMessages(template, null, orgWideAddress, managerUserIds, filters[0].eventRecord);
        }else{
            List<Contact> interviewers =  [SELECT ID, Name, User_Record__c, User_Record__r.Email FROM Contact WHERE GDC_Job_Posting__c includes (:filters[0].jobPosting) And GDC_Skill__c includes (:filters[0].skill) AND GDC_Hiring_Manager__c In :managers];
        List<Id> interviewerUsers = new List<Id>();
        for(Contact interviewer: interviewers) {
            if(interviewer.User_Record__c != null){
                interviewerUsers.add(interviewer.User_Record__c);   
            }
        }
            template = [SELECT ID, Name, Body from EmailTemplate where DeveloperName = 'GDC_Emergency_Slot_Mail' limit 1];
            sendEmailMessages(template, managerUserIds, orgWideAddress, interviewerUsers, filters[0].eventRecord);
        }
        
        return null;
    }
    
    private static void sendEmailMessages(EmailTemplate template, List<String> managerIds, OrgWideEmailAddress orgWideAddress, List<String> interviewerUserIds, Event event) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, UserInfo.getUserId(), event.Id);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(mail.getPlainTextBody());
        mail.setSubject(mail.getSubject());
        mail.setTargetObjectId(UserInfo.getUserId());
        
        if(orgWideAddress != null) {
            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        mail.setToAddresses(interviewerUserIds);
        mail.setCcAddresses(managerIds);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail}, false);
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }

    public class FiltersWrapper {
        @InvocableVariable public String hiringManager;
        @InvocableVariable public String jobPosting;
        @InvocableVariable public String skill;
        @InvocableVariable public Event eventRecord;
        @InvocableVariable public String identifier;
    }
}