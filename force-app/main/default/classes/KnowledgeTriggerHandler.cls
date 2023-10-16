public with sharing class KnowledgeTriggerHandler {
    public static void validateIsReviewed(List<Knowledge__kav> newRecords,Map<Id,Knowledge__kav> oldRecordsMap){
        for(Knowledge__kav each:newRecords){
            if(each.ValidationStatus != oldRecordsMap.get(each.Id).ValidationStatus && each.ValidationStatus == 'Validated' && !each.Is_Reviewed__c){
                each.AddError('Cannot approve article until "Is the Curation Level correct" field is checked.');
            }
        }
    }
}