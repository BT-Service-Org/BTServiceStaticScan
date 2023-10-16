public with sharing class ActivityGroupFilterController {
    
    @AuraEnabled(cacheable=false)
    public static List<Enablement_Activity__c> getActivitiesList(String enablementId, String domainId, String activityGroupId, String status, 
                                                                String category, String type, String priority, Integer dateFilter, String nameFilter, Boolean includeClosed) {
        System.debug('domainId='+domainId+ '  activityGroupId='+activityGroupId + '   status='+ status + '  dateFilter='+dateFilter);
        
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


        String query = 'SELECT Id, Name, Status__c, Expected_Start_Date__c, Expected_Completion_Date__c, Activity_Group_Name__c, Learning__c, Days_Left_to_Complete__c, IsClosed__c, ';
        query += ' Learning_Category__c, Priority__c, Hours_Required__c, Actual_Hours_Spent__c, Hours_Remaining__c ';
        query += ' FROM Enablement_Activity__c ';
        query += ' WHERE Activity_Group__r.Enablement_Journey__c= :enablementId ';
        
        if(String.isNotBlank(nameFilter)) {
            String actName = '%' + String.escapeSingleQuotes(nameFilter) + '%';
            query += ' AND Name LIKE :actName ';
            
        }

        if(String.isNotBlank(activityGroupId)) {
            query += ' AND Activity_Group__c= :activityGroupId ';
        }

        if(dateFilter != null) {
            query += ' AND Days_Left_to_Complete__c <= :dateFilter AND IsClosed__c = false ';
        }

        if(String.isNotBlank(status)) {
            query += ' AND Status__c= :status ';
        }
        
        if(String.isNotBlank(domainId) && learningIdsList.size() > 0) {
            query += ' AND Learning__c IN :learningIdsList ';
        }

        if(String.isNotBlank(category)) {
            query += ' AND Learning__r.Category__c = :category ';
        }

        if(String.isNotBlank(type)) {
            query += ' AND Learning__r.Type__c = :type ';
        }

        if(String.isNotBlank(priority)) {
            query += ' AND Priority__c = :priority ';
        }

        if(!includeClosed) {
            query += ' AND IsClosed__c = false ';
        }

        query += ' ORDER BY Activity_Group_Name__c ';

        System.debug('query='+query);
        System.debug('(List<Enablement_Activity__c>) Database.query(query)='+(List<Enablement_Activity__c>) Database.query(query));
        return (List<Enablement_Activity__c>) Database.query(query);
    }


    @AuraEnabled(cacheable=true)
    public static List< Enablement_Activity_Group__c > getActivityGroups(String enablementId) {
        return [SELECT Id, Name
            FROM Enablement_Activity_Group__c where Enablement_Journey__c= :enablementId
            ORDER BY Order__c];
    }


    @AuraEnabled(cacheable=true)
    public static List< Enablement_Journey_Domain__c > getAllDomains(String enablementId) {
        return [SELECT Id, Domain_Name__c, Enablement_Domain__c FROM Enablement_Journey_Domain__c WHERE Enablement_Journey__c = :enablementId AND Is_Active__c = true ORDER BY Domain_Name__c];
    }

    @AuraEnabled(cacheable=false)
    public static List<Enablement_Activity__c> updateActivityStatus(List<String> activityIds, String statusToBeUpdated, 
                                        String enablementId, String domainId, String activityGroupId, String status, 
                                        String category, String type, String priority, Integer dateFilter, String nameFilter, Boolean includeClosed) {
        List<Enablement_Activity__c> activityList = new List<Enablement_Activity__c>();
        Enablement_Activity__c enAct = new Enablement_Activity__c();
        for(String actId :activityIds ) {
            enAct = new Enablement_Activity__c();
            enAct.Id = actId;
            enAct.Status__c = statusToBeUpdated;
            activityList.add(enAct);
        }
        update activityList;

        List<Enablement_Activity__c> enList = getActivitiesList( enablementId, domainId, activityGroupId, status,  category, type, priority, dateFilter, nameFilter, includeClosed);

        System.debug('enList='+enList);

        return enList;
    }


}