public with sharing class SolutionFinderDetail {
    
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String url {get;set;}

    public SolutionFinderDetail(Solution_Finder_Detail__mdt record) {
        this.name = record.DeveloperName;
        this.label = record.Label__c;
        this.url = record.URL__c;
    }

    public String getMasterLabel() {
        return this.label.length() > 40 ? this.label.substring(0, 40) : this.label;
    }
}