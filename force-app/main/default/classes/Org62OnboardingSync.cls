//Creates onboarding records for inserted contacts
global class Org62OnboardingSync implements Database.Batchable<sObject> {
    global String query; 
    global System.LoggingLevel level = LoggingLevel.ERROR;
    
    global Integer jobno;
    private Id jobId;
    private Id acctId;
    private String errorLog = '';
        
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        acctId = [select id, name from Account where name = 'Salesforce.com - DO NOT TOUCH'].Id;
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC,List<sobject> scope) {
        System.debug('scope ' + scope);
        List<Id> uIds = new List<Id>();
        Map<Id, PA_Onboarding__c> updOnbMap = new Map<Id, PA_Onboarding__c>();
        Set<Id> crtOnbIds = new Set<Id>();
        Set<Id> crtcontacts = new Set<Id>();
        List<PA_Onboarding__c> onbLs = new List<PA_Onboarding__c>();
        Map<String, Id> recordTypes = OrgRefresh_Util.getRecordTypes();
        
        for (sObject s : scope) {
            System.debug('User ' + s);
            User u = (User) s;
            uIds.add(u.Id);
            System.debug('user id ' + u.Id + u.IsActive);
            
            Contact[] c = u.ContactRecord__r;
            System.debug('contact arr ' + c);
            if (u != null && u.IsActive == true && (c == null || c.size() == 0) ) {
                crtcontacts.add(u.id);
            }
            
            PA_Onboarding__c[] onbarr = u.PA_Onboardings__r;
            System.debug('onboarding arr ' + onbarr);
            if (onbarr != null && onbarr.size() == 1) {
                PA_Onboarding__c onb = onbarr[0];
                if (u.IsActive) {
                    if (u.CSG_Role__c != null) {
                        onb.Level__c = u.CSG_Role__c;
                    }
                    if (u.Community__c != null) {
                        onb.CSG_Role_Community__c = u.Community__c;
                    }
                    
                    if (u.Community__c != null && recordTypes.get(u.Community__c+u.CSG_Role__c) != null) {
                        onb.RecordTypeId = recordTypes.get(u.Community__c+u.CSG_Role__c);
                    }
                } else {
                    onb.Status__c = 'External Attrition';
                }
                onbLs.add(onb);
            } else if (u != null && u.IsActive == true && (onbarr == null || onbarr.size() == 0) && (c != null && c.size() == 1)) {
                Contact con = c[0];
                crtOnbIds.add(con.id);
            }
            
        }
        System.debug('crt contact ids ' + crtcontacts);
        System.debug('crt onb ids ' + crtOnbIds);
        
        //create contact records
        Util.inFutureContext = true;
        try {
            Set<Id> insContacts = UserContactUtil.createContact(crtcontacts, acctId);
            System.debug('inserted contact ids ' + insContacts);
            crtOnbIds.addAll(insContacts);
        } catch (Exception e) {
            System.debug('error creating contacts ' + e);
        }
        System.debug('creating onboarding records : '+ crtOnbIds);
        //create onboarding records
        try {
            LPOnboardingTriggerHandler.createPAOnboardingRecords(crtOnbIds);
        } catch (Exception e) {
            System.debug('error creating onboarding records ' + crtOnbIds + e);
        }
        //update onboarding records
        try {
            System.debug('upd onb ls ' + onbLs);
            if (onbLs.size() > 0) Database.update(onbLs);
        } catch (Exception e) {
            System.debug('error updating onboarding records ' + onbls + e);
        }
         
        
    }
    
    global void finish(Database.BatchableContext BC) {
        //updateJobStatusLog(jobId, BC, errorLog);
       
    }
}