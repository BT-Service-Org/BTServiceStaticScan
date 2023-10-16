/*****************************************
* File: LPOnboardingTriggerHandler
* Author: William Steele-Salesforce PA
* Description: Trigger Handler logic from Contact for PA_Onboarding__c records
******************************************/
public class LPOnboardingTriggerHandler implements IXTriggerHandler {
    // You can set this static boolean from apex in this namespace if you want to bypass this trigger
    public static Boolean disable = false;

    public Boolean isDisabled() {
        return disable;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<Contact> newSObjects = (List<Contact>) newItems;
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Contact> newSObjects = (Map<Id, Contact>) newItems;
        Map<Id, Contact> oldSObjects = (Map<Id, Contact>) oldItems;
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, Contact> oldSObjects = (Map<Id, Contact>) oldItems;
    }

    public void afterInsert(List<SObject> newItems) {
        List<Contact> newSObjects = (List<Contact>) newItems;
        Set<Id> contactIds = new Set<Id>();
        for (Contact c: newSObjects) {
            contactIds.add(c.Id);
        }
        createPAOnboardingRecords(contactIds);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Contact> newSObjects = (Map<Id, Contact>) newItems;
        Map<Id, Contact> oldSObjects = (Map<Id, Contact>) oldItems;
        updatePAOnboardingRecords(newSObjects);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, Contact> oldSObjects = (Map<Id, Contact>) oldItems;
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
        Map<Id, Contact> oldSObjects = (Map<Id, Contact>) oldItems;
    }

    /* Custom Methods */

    /**
     * @description Creates PA Onboarding records for contacts that are created for Advisory services.
     * @param passedPAs, the List of Contact records to process.
     */
    public static void createPAOnboardingRecords(Set<Id>  passedPAIds) {
        
        
        List<Contact> passedPAs = 
            [select Id,UserId__c,Name,Role__c,OwnerId,Region__c,Hire_Date__c,User_Record__r.Community__c, 
                    User_Record__r.Hire_Date__c, User_Record__r.Email, User_Record__r.CSG_Role__c, 
                        User_Record__c, job_grade__c, User_Record__r.Primary_Coverage_Country__c from Contact where Id=:passedPAIds];
        if (passedPAs.size() <= 0) return;
        
            
        List<PA_Onboarding__c> newPAs = new List<PA_Onboarding__c>();
        PA_Onboarding__c newPA = new PA_Onboarding__c();
        
        //Id recordTypeId = [select Id from RecordType where Name Like 'PA Onboarding' Limit 1].Id;
        Map<String, Id> recordTypes = OrgRefresh_Util.getRecordTypes();
        System.Debug('UserSync RecordTypes: ' + recordTypes);

        //SCT 08-27-20 list of strings of PCC values from contacts
        List<String> geoStrings = new List<String>(); 
        for(Contact c: passedPAs){
            geoStrings.add(c.User_Record__r.Primary_Coverage_Country__c);
        }

		//SCT 08-27-20 create map to store corresponding geo id to pcc from user 
        Map<String, String> geoMap = new map<String, string>();        
        //SCT 08-27-20 query the Onboarding Map for PCC values to get geo
        //SCT 08-27-20 populate the map
        if(geoStrings!=null)
        for(Onboarding_Mapping__c o : [SELECT Id, Name, Geo__c FROM Onboarding_Mapping__c 
                                            WHERE Name IN: geoStrings] ){
            geoMap.put(o.Name, o.Geo__c);
        }
        
        for (Contact c: passedPAs) {
            
            System.debug('createPAOnboardingRecords:Hire_Date__c: '+c);
            if (c.User_Record__c != null) {
                newPA = new PA_Onboarding__c(
                    Candidate__c            = c.User_Record__c, 
                    Candidate_Email__c      = c.User_Record__r.Email, 
                    Contact__c              = c.Id,
                    OwnerId                 = c.OwnerId,
                    Program_Start_Date__c   = c.User_Record__r.Hire_Date__c,
                    Name                    = c.Name,
                    Geo_From_Map__c			= geoMap.get(c.User_Record__r.Primary_Coverage_Country__c)//SCT 08-27-2020 map to Geo 
                );
                
                System.Debug('c.User_Record__r.Community__c: ' + c.User_Record__r.Community__c);
                System.Debug('c.User_Record__r.CSG_Role__c: ' + c.User_Record__r.CSG_Role__c);
                System.Debug('recordTypes.get(c.User_Record__r.Community__c+c.User_Record__r.CSG_Role__c): ' + recordTypes.get(c.User_Record__r.Community__c+c.User_Record__r.CSG_Role__c));
                // Sriram Venkatraman 8/7/2019 - Added code this condition since OrgRefresh_Util.getRecordTypes() method
                // is actually concatinating Community & Role together to get the right Row ID. Not sure 
                // how the existing code; Yet introducing this if condition to ensure proper custom metadata type
                // "UserSync" row is picked.
                if (recordTypes.get(c.User_Record__r.Community__c + c.User_Record__r.CSG_Role__c) != null) {
                    newPA.RecordTypeId = recordTypes.get(c.User_Record__r.Community__c+c.User_Record__r.CSG_Role__c);
                }
                // Sriram Venkatraman 8/7/2019
                
                if (c.User_Record__r.Community__c != null && recordTypes.get(c.User_Record__r.Community__c) != null) {
                    newPA.RecordTypeId = recordTypes.get(c.User_Record__r.Community__c);
                }
                
                if (c.User_Record__r.Hire_Date__c == null) {
                    newPA.Program_Start_Date__c = System.today();
                }
                
                if (c.User_Record__r.CSG_Role__c != null) {
                    newPA.Level__c = c.User_Record__r.CSG_Role__c;
                }
                
                if (c.User_Record__r.Community__c != null) {
                    newPA.CSG_Role_Community__c = c.User_Record__r.Community__c;
                    //Ankit garg - 05/23/2021 - Added Delivery Hub logic to PA record.
                    if(c.Job_Grade__c!=null){
                        newPA.Delivery_Hub__c = fetchDeliverHub(c.User_Record__r.Community__c,c.Job_Grade__c);
                    }
                }
                
                System.debug('@@createPAOnboardingRecords:created new PA record: '+newPA);
                newPAs.add(newPA);
            }
        }
        Database.SaveResult[] srList = Database.insert(newPAs, false);

        // Sriram Venkatraman 8/7/2019. Adding this result eval for better Debugging.
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Onboarding. Onboarding ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Onboarding fields that affected this error: ' + err.getFields());
                }
            }
        }
        // Sriram Venkatraman 8/7/2019.
    }

    public static Boolean fetchDeliverHub(String role, String jobGrade){
        List<PA_Onboarding_Mappings__mdt> deliveryHubValues = [Select Delivery_Hub__c from PA_Onboarding_Mappings__mdt where CSG_Role__c=:role AND User_Job_Grade__c= :jobGrade];
        if(deliveryHubValues.size()==1){
            return deliveryHubValues[0].Delivery_Hub__c;
        }
        return false;
    }
    public static void updatePAOnboardingRecords( Map<id,Contact> contactMap){
        List<PA_Onboarding__c> onboaringRecords = [SELECT Id,Delivery_Hub__c,CSG_Role_Community__c, Contact__r.Job_Grade__c from PA_Onboarding__c where Contact__c in :contactMap.keyset() ];
        
        for(PA_Onboarding__c oldPA: onboaringRecords){
            
            if(oldPA.CSG_Role_Community__c!=null && oldPA.contact__r.Job_Grade__c!=null)
            oldPA.Delivery_Hub__c= fetchDeliverHub(oldPA.CSG_Role_Community__c, oldPA.Contact__r.Job_Grade__c);
            
        }
       try{
        update onboaringRecords;
       }
       catch(Exception ex){
            System.debug('Exception'+ex);
       }
    }

}