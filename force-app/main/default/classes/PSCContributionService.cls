public with sharing class PSCContributionService {
    public static void updateContentDocumentLink(String contentIdString, Id recordId){
        try {
            List<Id> contentIds = (List<Id>) JSON.deserialize(contentIdString, List<Id>.class);
            List<ContentDocumentLink> updatedContentDocumentLink = new List<ContentDocumentLink>();
            if(contentIds != null && !contentIds.isEmpty()){
                for(ContentDocumentLink contentLink : [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink Where ContentDocumentId In :contentIds]){
                    ContentDocumentLink updatedContentLink = contentLink.clone();
                    updatedContentLink.LinkedEntityId = recordId;
                    updatedContentDocumentLink.add(updatedContentLink);
                }
                insert updatedContentDocumentLink;
            }
        } catch (Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void deleteContentDocument(String contentIdString){
        try {
            List<Id> contentIds = (List<Id>) JSON.deserialize(contentIdString, List<Id>.class);
            List<ContentDocument> orphanContentDocument = new List<ContentDocument>([SELECT Id FROM ContentDocument Where Id In :contentIds]);
            delete orphanContentDocument;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}