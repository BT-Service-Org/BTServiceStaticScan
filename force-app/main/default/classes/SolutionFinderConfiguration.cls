public with sharing class SolutionFinderConfiguration {
    
    @AuraEnabled public Id id {get;set;}
    @AuraEnabled public String optionName {get;set;}
    @AuraEnabled public String solutionName {get;set;}
    @AuraEnabled public String properties {get;set;}
    @AuraEnabled public List<SolutionFinderPropertyValue> propertyValues {get;set;}

    public SolutionFinderConfiguration(Solution_Finder_Configuration__c record) {
        this.id = record.Id;
        this.optionName = record.Option_Name__c;
        this.solutionName = record.Solution_Name__c;
        this.properties = record.Properties__c;
        this.propertyValues = new List<SolutionFinderPropertyValue>();
    }

    public void addPropertyValue(Id configurationId, Object value, SolutionFinderProperty property) {
        this.propertyValues.add(new SolutionFinderPropertyValue(configurationId, value, property));
    }

    @AuraEnabled
    public static void deleteConfiguration(Id configurationId){
        List<Solution_Finder_Configuration__c> configurations =
            [SELECT Id
             FROM Solution_Finder_Configuration__c
             WHERE Id = : configurationId
             WITH SECURITY_ENFORCED
             LIMIT 1];
        if (configurations.size() > 0) {
            delete configurations;
        }
    }
}