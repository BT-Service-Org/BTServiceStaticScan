public with sharing class SolutionFinderPropertyValue {
    
    @AuraEnabled public Id configurationId {get;set;}
    @AuraEnabled public Object value {get;set;}
    @AuraEnabled public SolutionFinderProperty property {get;set;}

    public SolutionFinderPropertyValue(id configurationId, Object value, SolutionFinderProperty property) {
        this.configurationId = configurationId;
        this.value = value;
        this.property = property;
    }
}