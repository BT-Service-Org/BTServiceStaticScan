public with sharing class SolutionFinder {

    @AuraEnabled
    public static SolutionFinderSettings getSettings() {
        SolutionFinderSettings settings = new SolutionFinderSettings();
        List<Solution_Finder_Settings__mdt> records =
            [SELECT Id, Namespace__c, Parent_Namespace__c, Parent_Name__c,
                    Default_Feedback_Slack_Channel__c, Default_Feedback_Email__c
                FROM Solution_Finder_Settings__mdt
                WITH SECURITY_ENFORCED
                LIMIT 1];
        if (records.size() > 0) {
            settings = new SolutionFinderSettings(records[0]);
        }
        return settings;
    }
}