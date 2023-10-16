/**
* @param contentIdString 
**/
public with sharing class PSCRequestContentCtrl {
        @AuraEnabled
        public static void createContentRequest(Id requestContentId, String contentIdString){
            try {
                if(requestContentId != null && String.isNotBlank(contentIdString)){
                    PSCContributionService.updateContentDocumentLink(contentIdString, requestContentId);
                }
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
}