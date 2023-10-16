public with sharing class SolutionFinderProject {
    
    @AuraEnabled public Id id {get;set;}
    @AuraEnabled public String name {get;set;}

    public SolutionFinderProject(Solution_Finder_Project__c record) {
        this.id = record.Id;
        this.name = record.Name;
    }
}