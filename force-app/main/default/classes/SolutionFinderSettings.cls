public with sharing class SolutionFinderSettings {

    @AuraEnabled public String namespace {get;set;}
    @AuraEnabled public String parentNamespace {get;set;}
    @AuraEnabled public String parentName {get;set;}
    @AuraEnabled public String defaultFeedbackSlackChannel {get;set;}
    @AuraEnabled public String defaultFeedbackEmail {get;set;}

    public SolutionFinderSettings() {}

    public SolutionFinderSettings(Solution_Finder_Settings__mdt record) {
        this.namespace = record.Namespace__c;
        this.parentNamespace = record.Parent_Namespace__c;
        this.parentName = record.Parent_Name__c;
        this.defaultFeedbackSlackChannel = record.Default_Feedback_Slack_Channel__c;
        this.defaultFeedbackEmail = record.Default_Feedback_Email__c;
    }

    @AuraEnabled
    public static Id saveSettings(String namespace, String parentNamespace, String parentName, String feedbackSlackChannel, String feedbackEmail) {

        String name = 'Default';
        String masterLabel = 'Default';

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Settings__mdt', name, masterLabel);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Parent_Namespace__c', parentNamespace);
        request.addProperty('Parent_Name__c', parentName);
        request.addProperty('Default_Feedback_Slack_Channel__c', feedbackSlackChannel);
        request.addProperty('Default_Feedback_Email__c', feedbackEmail);
        return request.execute();
    }
}