public with sharing class SolutionFinderActivity {

    @AuraEnabled
    public static void saveActivity(String recordTypeName, String parentOptionName, String optionName, String solutionName, Decimal quantity) {

        Id recordTypeId = getRecordTypeId(recordTypeName);
        if (recordTypeId == null) {
            return;
        }

        Solution_Finder_Activity__c activity = new Solution_Finder_Activity__c();
        activity.RecordTypeId = recordTypeId;
        activity.Parent_Option_Name__c = parentOptionName;
        activity.Option_Name__c = optionName;
        activity.Solution_Name__c = solutionName;
        activity.Quantity__c = quantity;
        insert activity;
    }

    private static Id getRecordTypeId(String recordTypeName) {
        Id recordTypeId;
        try {
            recordTypeId = Schema.SObjectType.Solution_Finder_Activity__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        } catch (Exception e) {
            System.debug('Error getting record type name: ' + e);
        }
        return recordTypeId;
    }
}