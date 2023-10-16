public with sharing class ActivityGroupTemplateFiltersController {


    @AuraEnabled(cacheable=false)
    public static List<EnablementItemWrapper> getEnablementItemsList(String actGroupId, String templateId, String activityGroupId,  
                                                                    String domainId, String category, String priority, String selectedShowOption) {
        System.debug('actGroupId='+actGroupId + ' templateId ='+templateId + ' category='+category +' priority='+priority );
        List<EnablementItemWrapper> enablementItems = new List<EnablementItemWrapper>();
        //Get the current activity group record
        Enablement_Activity_Group__c actGroup = [ SELECT Id, Enablement_Journey__c FROM Enablement_Activity_Group__c WHERE Id = :actGroupId];
        
        //Create a map of enablement item id to activity group under the CURRENT JOURNEY
        Map<Id, String> enItemtoActGroupMap = new Map<Id, String>();
        Set<Id> activitiesInThisGroup = new Set<Id>();
        for(Enablement_Activity__c enAct :[ SELECT  Activity_Group__c, Activity_Group_Name__c, Learning__c, Publish__c 
                                            FROM    Enablement_Activity__c 
                                            WHERE   Activity_Group__r.Enablement_Journey__c = :actGroup.Enablement_Journey__c])
        {
            enItemtoActGroupMap.put(enAct.Learning__c, enAct.Activity_Group_Name__c);
            //if the enablement activity's group is the current group
            if(enAct.Activity_Group__c == actGroup.Id) {
                activitiesInThisGroup.add(enAct.Learning__c);
            }
            
        }

        //ASSIGN VALUES BASED ON selectedShowOption
        //If the "All activites in this group" filter is selected

        if(selectedShowOption == 'group') {
            templateId = actGroup.Enablement_Journey__c;
            activityGroupId = actGroup.Id;
        }

        //Get all the Enablement Items associated with the enablement domains
        //And create the list of wrapper
        EnablementItemWrapper enItem;

        //If no filters are selected for template, show all the enablement items associated with enablement journey domains
        if(String.isBlank(templateId)) {
            Boolean whereAdded = false;

            String query =  ' SELECT Id, Onboarding_Domain__c, Onboarding_Domain__r.Name, Learning__c, Learning__r.Name ';
            query +=        ' FROM Enablement_Item_Domain__c ';

            if(String.isNotBlank(domainId)) {
                query += ' WHERE Onboarding_Domain__c = :domainId ';
                whereAdded = true;
            }
            if(String.isNotBlank(category)) {
                if(whereAdded) { query += ' AND '; }
                else { 
                    query += ' WHERE '; 
                    whereAdded = true;
                }
                query += ' Learning__r.Category__c = :category';
            }

            Set<Id> addedLearnings = new Set<Id>();
            for(Enablement_Item_Domain__c enablementItemDomain :(List<Enablement_Item_Domain__c>)Database.query(query))
            {
                enItem = new EnablementItemWrapper();
                enItem.enablementItemName = enablementItemDomain.Learning__r.Name;
                enItem.Id = enablementItemDomain.Learning__c;
                enItem.enablementItemStatus = 'Not Started';
                enItem.enablementItemDomain = enablementItemDomain.Onboarding_Domain__r.Name;

                if(enItemtoActGroupMap.containsKey(enablementItemDomain.Learning__c)) {
                    enItem.enablementItemActivityGroup = enItemtoActGroupMap.get(enablementItemDomain.Learning__c);
                }

                // if selected show option is "Not in this group", do not add the record to be displayed
                if(selectedShowOption == 'notgroup' && activitiesInThisGroup.contains(enablementItemDomain.Learning__c)) {
                    continue;
                } 
                // if selected show option is "Not in this journey", do not add the record to be displayed
                else if(selectedShowOption == 'notjourney' && enItemtoActGroupMap.containsKey(enablementItemDomain.Learning__c)) {
                    continue;
                } 
                //check if activity is already added
                else if(!addedLearnings.contains(enablementItemDomain.Learning__c)){
                    enablementItems.add(enItem);
                    addedLearnings.add(enablementItemDomain.Learning__c);
                }
            }
        }
        //if a template is selected 
        else {

            //Get the enablement domains associated with the Journey
            Set<Id> domainIdsSet = new Set<Id>();
            List<Id> domainIdsList = new List<Id>();

            for(Enablement_Journey_Domain__c enJourneyDomain 
                :[  SELECT  Id, Enablement_Domain__c, Enablement_Domain__r.Name 
                    FROM    Enablement_Journey_Domain__c 
                    WHERE   Enablement_Journey__c = :actGroup.Enablement_Journey__c])
            {
                domainIdsSet.add(enJourneyDomain.Enablement_Domain__c);
            }
            domainIdsList.addAll(domainIdsSet);

            //get learnings and domains
            Map<Id, String> enItemtoDomainMap = new Map<Id, String>();

            for(Enablement_Item_Domain__c enItemDomain 
                :[  SELECT  Id, Onboarding_Domain__c, Onboarding_Domain__r.Name, Learning__c, Learning__r.Name 
                    FROM    Enablement_Item_Domain__c 
                    WHERE   Onboarding_Domain__c IN :domainIdsList])
            {
                enItemtoDomainMap.put(enItemDomain.Learning__c, enItemDomain.Onboarding_Domain__r.Name);
            }

            Set<Id> learningIds = new Set<Id>();
            List<Id> learningIdsList = new List<Id>();
            if(String.isNotBlank(domainId)) {
                for (Enablement_Item_Domain__c ld: [SELECT Id, Name, Learning__c
                                            FROM Enablement_Item_Domain__c
                                            WHERE Onboarding_Domain__c = :domainId])
                {
                    learningIds.add(ld.Learning__c);
                }
                learningIdsList.addAll(learningIds);
            }

            //Query Enablement Activities based on the selected filters
            String query = 'SELECT Id, Name, Status__c, Expected_Completion_Date__c, Activity_Group_Name__c, Learning__c, Learning__r.Name, Days_Left_to_Complete__c, IsClosed__c, ';
            query += ' Learning_Category__c, Priority__c, Hours_Required__c, Actual_Hours_Spent__c, Hours_Remaining__c, Days_Until_Start__c,Days_To_Complete__c, Publish__c  ';
            query += ' FROM Enablement_Activity__c ';
            query += ' WHERE Activity_Group__r.Enablement_Journey__c= :templateId ';
    
            if(String.isNotBlank(activityGroupId)) {
                query += ' AND Activity_Group__c = :activityGroupId ';
            }
            if(String.isNotBlank(category)) {
                query += ' AND Learning__r.Category__c = :category ';
            }
            if(String.isNotBlank(priority)) {
                query += ' AND Priority__c = :priority ';
            }
            if(String.isNotBlank(domainId) && learningIdsList.size() > 0) {
                query += ' AND Learning__c IN :learningIdsList ';
            }
            query += ' ORDER BY Activity_Group_Name__c';

            System.debug('query='+query);

            //Create a list of wrapper class to be displayed on the UI
            for(Enablement_Activity__c enAct :(List<Enablement_Activity__c>)Database.query(query))
            {   
                if(enAct.Learning__c != null) {       
                    enItem = new EnablementItemWrapper();
                    enItem.enablementItemName = enAct.Name;
                    /*if(enAct.Learning__c != null && selectedShowOption != 'group') {
                        enItem.enablementItemName = enAct.Learning__r.Name;
                    } else {
                        enItem.enablementItemName = enAct.Name;
                    }*/
                    enItem.Id = enAct.Id;
                    enItem.publish = enAct.Publish__c;
                    enItem.enablementItemStatus = enAct.Status__c;
                    if(enItemtoDomainMap.containsKey(enAct.Learning__c)) {
                        enItem.enablementItemDomain = enItemtoDomainMap.get(enAct.Learning__c);
                    }
                    enItem.enablementItemStartDays = Integer.valueOf(enAct.Days_Until_Start__c);
                    enItem.enablementItemDuration = Integer.valueOf(enAct.Days_To_Complete__c);
                    //if the item already exist as an activity
                    if(enItemtoActGroupMap.containsKey(enAct.Learning__c)) {
                        enItem.enablementItemActivityGroup = enItemtoActGroupMap.get(enAct.Learning__c);
                        enItem.enablementItemName = enAct.Name;
                    } else if(enAct.Learning__c != null){
                        enItem.Id = enAct.Learning__c;
                    }

                    // if selected show option is "Not in this group", do not add the record to be displayed
                    if(selectedShowOption == 'notgroup' && activitiesInThisGroup.contains(enAct.Learning__c)) {
                        continue;
                    } else if(selectedShowOption == 'notjourney' && enItemtoActGroupMap.containsKey(enAct.Learning__c)) {
                        continue;
                    } else {
                        enablementItems.add(enItem);
                    }
                }
            }
            System.debug('enablementItems='+enablementItems);
        }

        return enablementItems;
    }
    
                                                                

    
    @AuraEnabled(cacheable=false)
    public static List< Enablement_Activity_Group__c > getActivityGroups(String enablementId) {
        return [SELECT Id, Name
            FROM Enablement_Activity_Group__c where Enablement_Journey__c= :enablementId
            WITH SECURITY_ENFORCED
            ORDER BY Order__c ];
    }


    @AuraEnabled(cacheable=true)
    public static List< Enablement_Journey__c > getAllTemplates() {
        Id templateRecordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Template').getRecordTypeId();
        return [SELECT Id, Name FROM Enablement_Journey__c WHERE RecordTypeId = :templateRecordTypeId AND IsActive__c = true ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List< Enablement_Journey_Domain__c > getAllDomains(String actGroupId) {
        Enablement_Activity_Group__c actGroup = [ SELECT Id, Enablement_Journey__c FROM Enablement_Activity_Group__c WHERE Id = :actGroupId];
        return [SELECT Id, Domain_Name__c, Enablement_Domain__c FROM Enablement_Journey_Domain__c WHERE Enablement_Journey__c = :actGroup.Enablement_Journey__c AND Is_Active__c = true ORDER BY Domain_Name__c];
    }

    //This method creates Enablement Activity records under the group
    @AuraEnabled(cacheable=false)
    public static Boolean addActivities(String enablementGroupId, List<String> selectedItems ) {
        System.debug('selecteditems='+selectedItems);
        List<Enablement_Activity__c> activitiesToUpsert = new List<Enablement_Activity__c>();

        for(Object item :selectedItems) {
            EnablementItemWrapper selectedItem = (EnablementItemWrapper) JSON.deserialize(String.valueOf(item), EnablementItemWrapper.class);
            System.debug('String.valueOf(item)='+String.valueOf(item));
            System.debug('selectedItem='+selectedItem);

            String sObjName = Id.valueOf(selectedItem.Id).getSObjectType().getDescribe().getName();
            Enablement_Activity__c enAct;
            //If id is enablement item id, create a new enablement activity
            if(sObjName == 'Enablement_Item__c') {
                enAct = new Enablement_Activity__c();
                enAct.Activity_Group__c = enablementGroupId;
                enAct.Learning__c = selectedItem.Id;
                enAct.Name = selectedItem.enablementItemName;
                activitiesToUpsert.add(enAct);
            }
            //If id is enablement activity id, reparent it to the enablement group
            else if(sObjName == 'Enablement_Activity__c') {
                enAct = new Enablement_Activity__c();
                enAct.Id = selectedItem.Id;
                enAct.Activity_Group__c = enablementGroupId;
                enAct.Days_Until_Start__c = selectedItem.enablementItemStartDays;
                enAct.Days_To_Complete__c = selectedItem.enablementItemDuration;
                enAct.Publish__c = selectedItem.publish;
                activitiesToUpsert.add(enAct);
            }
        }

        upsert activitiesToUpsert;
        return true;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean removeActivities(String enablementGroupId, List<String> enablementItemIds ) {
        List<Enablement_Activity__c> activitiesToDelete = new List<Enablement_Activity__c>();

        for(String itemId :enablementItemIds) {
            activitiesToDelete.add(new Enablement_Activity__c(id = itemId));            
        }

        delete activitiesToDelete;
        return true;
    }
 

    
    public class EnablementItemWrapper{

        @AuraEnabled public Id Id {get;set;}
        @AuraEnabled public String enablementItemName {get;set;}
        @AuraEnabled public String enablementItemStatus {get;set;}
        @AuraEnabled public Integer enablementItemStartDays {get;set;}
        @AuraEnabled public Integer enablementItemDuration {get;set;}
        @AuraEnabled public Boolean publish {get;set;}
        @AuraEnabled public String enablementItemDomain {get;set;}
        @AuraEnabled public String enablementItemActivityGroup {get;set;}
    }
    
}