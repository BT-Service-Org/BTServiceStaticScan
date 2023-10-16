public with sharing class PSCFeedbackContributionCtrl {
    
    @AuraEnabled(Cacheable=true)
    public static List<FeedbackButtonWrapper> getFeedbackData(){
        List<FeedbackButtonWrapper> feedbackDataList;
        try {
            String feedbackJson = PSCSettingService.getValue('PSC_Feedback_Contribution');
            feedbackDataList = (List<FeedbackButtonWrapper>) JSON.deserialize(feedbackJson, List<FeedbackButtonWrapper>.class);
            for(FeedbackButtonWrapper feedbackButton : feedbackDataList){
                if(feedbackButton.recordTypeDevName != null){
                    feedbackButton.recordTypeId = Schema.getGlobalDescribe().get(feedbackButton.sobjectName)?.getDescribe()?.getRecordTypeInfosByDeveloperName()?.get(feedbackButton.recordTypeDevName)?.getRecordTypeId();
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return feedbackDataList;
    }

    @AuraEnabled
    public static void updateContentDocumentLink(String contentIdString, Id recordId){
        try {
            PSCContributionService.updateContentDocumentLink(contentIdString, recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FeedbackButtonWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String sobjectName;
        @AuraEnabled
        public String recordTypeDevName;
        @AuraEnabled
        public Id recordTypeId;
        @AuraEnabled
        public FeedbackModalWrapper onClickModal;
    }

    public class FeedbackModalWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public List<FeedbackModalFieldWrapper> modalFieldList;
    }

    public class FeedbackModalFieldWrapper{
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public Boolean inputField;
        @AuraEnabled
        public Boolean fileUpload;
        @AuraEnabled
        public Boolean customRadioGroup;
        @AuraEnabled
        public String otherFieldName;
    }
}