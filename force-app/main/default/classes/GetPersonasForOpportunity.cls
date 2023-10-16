public with sharing class GetPersonasForOpportunity {
    private static final String SALESFORCE_ACCOUNT_NAME='';
    @AuraEnabled(cacheable=false)
    public static List<MAPInterview__c> getPersonasForOpportunity(String opptyId) {
        List<Id> assessmentIds = new List<Id>();
        for(MAPAssessment__c assessment : [ select Id from MAPAssessment__c 
                                            where Opportunity__c=:opptyId]){
            assessmentIds.add(assessment.id);
        }
        return [
            select Id,Name,Assessment__c,
                    Assessment__r.Name,
                    Assessment__r.Summary__c,
                    Domain__c,
                    Persona__r.Name,
                    Persona__c
            from MapInterview__c
            where Assessment__c in :assessmentIds

        ];
    }
}