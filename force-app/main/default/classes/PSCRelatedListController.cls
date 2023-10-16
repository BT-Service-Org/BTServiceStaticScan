public with sharing class PSCRelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<Article_Tags__c> fetchTargetAudience(String relatedRecordId, String relationshipName, String recordtypename){
        try {
            String knowledgeQuery;
            String sanitRelatedRecordId = String.escapeSingleQuotes(relatedRecordId);
            String sanitrecordtypename= String.escapeSingleQuotes(recordtypename);
            Id recordTypeId =Schema.SObjectType.Article_Tags__c.getRecordTypeInfosByName().get(sanitrecordtypename).getRecordTypeId();
            if(sanitrecordtypename =='Role Family Relationship'){
             knowledgeQuery = 'SELECT Id,Role_Family__r.Name,Tag__r.Name FROM Article_Tags__c WHERE '+String.escapeSingleQuotes(relationshipName)+' =:sanitRelatedRecordId AND RecordTypeId=:recordTypeId AND Role_Family__r.Name != null WITH USER_MODE';
            }
            else if(sanitrecordtypename =='Tag Relationship'){
             knowledgeQuery = 'SELECT Id,Role_Family__r.Name,Tag__r.Name FROM Article_Tags__c WHERE '+String.escapeSingleQuotes(relationshipName)+' =:sanitRelatedRecordId AND RecordTypeId=:recordTypeId AND Tag__r.Name != null WITH USER_MODE';
            }
            return Database.query(knowledgeQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}