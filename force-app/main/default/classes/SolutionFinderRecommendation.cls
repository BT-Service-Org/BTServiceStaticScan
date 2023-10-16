public with sharing class SolutionFinderRecommendation implements Comparable {

    @AuraEnabled public String solutionId {get;set;}
    @AuraEnabled public String solutionNamespace {get;set;}
    @AuraEnabled public String solutionName {get;set;}
    @AuraEnabled public String solutionLabel {get;set;}
    @AuraEnabled public Decimal percentage {get;set;}
    @AuraEnabled public String description {get;set;}
    @AuraEnabled public String exportNote {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> considerations {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> limitations {get;set;}
    @AuraEnabled public List<SolutionFinderDetail> stories {get;set;}
    @AuraEnabled public List<SolutionFinderProperty> properties {get;set;}

    public SolutionFinderRecommendation() {}

    public SolutionFinderRecommendation(Solution_Finder_Recommendation__mdt record) {
        this.solutionId = record.Solution_Finder_Solution__c;
        this.solutionNamespace = record.Solution_Finder_Solution__r.Namespace__c;
        this.solutionName = record.Solution_Finder_Solution__r.DeveloperName;
        this.solutionLabel = record.Solution_Finder_Solution__r.Title__c;
        this.percentage = record.Percentage__c;
        this.description = record.Solution_Finder_Solution__r.Description__c;
        this.exportNote = record.Solution_Finder_Solution__r.Export_Note__c;
        this.considerations = new List<SolutionFinderDetail>();
        this.limitations = new List<SolutionFinderDetail>();
        this.stories = new List<SolutionFinderDetail>();
        this.properties = new List<SolutionFinderProperty>();
    }

    public void setConsiderations(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.considerations.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setLimitations(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.limitations.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setStories(List<Solution_Finder_Detail__mdt> detailRecords) {
        for (Solution_Finder_Detail__mdt detailRecord : detailRecords) {
            this.stories.add(new SolutionFinderDetail(detailRecord));
        }
    }

    public void setProperties(List<Solution_Finder_Property__mdt> propertyRecords) {
        for (Solution_Finder_Property__mdt propertyRecord : propertyRecords) {
            this.properties.add(new SolutionFinderProperty(propertyRecord));
        }
    }

    @AuraEnabled
    public static Id saveRecommendation(String namespace, String name, String optionName, String solutionName) {

        if (optionName == null || solutionName == null) {
            return null;
        }

        String label = optionName + '_' + solutionName;
        if (name == null) {
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.RECOMMENDATION_INDEX_NAME);
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Recommendation__mdt', name, label);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Solution_Finder_Option__c', optionName);
        request.addProperty('Solution_Finder_Solution__c', solutionName);
        return request.execute();
    }

    @AuraEnabled
    public static Id deleteRecommendation(String name) {

        if (name == null) {
            return null;
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Recommendation__mdt', name, 'DELETED');
        request.addProperty('Solution_Finder_Option__c', null);
        request.addProperty('Solution_Finder_Solution__c', null);
        return request.execute();
    }

    public Integer compareTo(Object otherObject) {
        SolutionFinderRecommendation otherRecord = (SolutionFinderRecommendation)otherObject;
        if (this.solutionLabel == null || otherRecord.solutionLabel == null) {
            return 0;
        } else {
            return this.solutionLabel.compareTo(otherRecord.solutionLabel);
        }
    }
}