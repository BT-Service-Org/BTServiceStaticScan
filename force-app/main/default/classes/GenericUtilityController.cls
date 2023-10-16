public with sharing class GenericUtilityController {
    @AuraEnabled(cacheable=true)
    public static List<Article_Tags__c> fetchTargetAudience(String relatedRecordId, String relationshipName){
        try {
            String sanitRelatedRecordId = String.escapeSingleQuotes(relatedRecordId);
            String knowledgeQuery = 'SELECT Id,Role_Family__r.Name FROM Article_Tags__c WHERE '+String.escapeSingleQuotes(relationshipName)+' =:sanitRelatedRecordId AND Role_Family__r.Name != null WITH USER_MODE';
            return Database.query(knowledgeQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}