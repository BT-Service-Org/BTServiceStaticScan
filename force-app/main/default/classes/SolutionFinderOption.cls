public with sharing class SolutionFinderOption {

    @AuraEnabled public String namespace {get;set;}
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String parentNamespace {get;set;}
    @AuraEnabled public String parentName {get;set;}
    @AuraEnabled public String title {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String nextQuestion {get;set;}
    @AuraEnabled public String nextQuestionHelpText {get;set;}
    @AuraEnabled public String answerLabel {get;set;}
    @AuraEnabled public String questionLabel {get;set;}
    @AuraEnabled public String feedbackSlackChannel {get;set;}
    @AuraEnabled public String feedbackEmail {get;set;}

    public SolutionFinderOption(Solution_Finder_Option__mdt record) {
        this.namespace = record.Namespace__c;
        this.name = record.DeveloperName;
        this.parentNamespace = record.Parent_Namespace__c;
        this.parentName = record.Parent_Name__c;
        this.title = record.Title__c;
        this.description = record.Description__c;
        this.nextQuestion = record.Next_Question__c;
        this.nextQuestionHelpText = record.Next_Question_Help_Text__c;
        this.answerLabel = record.Answer_Label__c;
        this.questionLabel = record.Question_Label__c;
        this.feedbackSlackChannel = record.Feedback_Slack_Channel__c;
        this.feedbackEmail = record.Feedback_Email__c;
    }

    @AuraEnabled
    public static Id saveOption(String namespace, String name, String parentNamespace, String parentName, String title, String description,
            String nextQuestion, String nextQuestionHelpText, String feedbackSlackChannel, String feedbackEmail) {

        String masterLabel;
        if (title == null) {
            return null;
        } else {
            masterLabel = title.length() > 40 ? title.substring(0, 40) : title;
        }

        if (name == null) {
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.OPTION_INDEX_NAME);
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Option__mdt', name, masterLabel);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Title__c', title);
        request.addProperty('Parent_Namespace__c', parentNamespace);
        request.addProperty('Parent_Name__c', parentName);
        request.addProperty('Description__c', description);
        request.addProperty('Next_Question__c', nextQuestion);
        request.addProperty('Next_Question_Help_Text__c', nextQuestionHelpText);
        request.addProperty('Feedback_Slack_Channel__c', feedbackSlackChannel);
        request.addProperty('Feedback_Email__c', feedbackEmail);
        return request.execute();
    }
}