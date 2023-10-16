public with sharing class SolutionFinderComparisonProperty {
    
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String title {get;set;}
    @AuraEnabled public String dataType {get;set;}
    @AuraEnabled public Decimal decimalPlaces {get;set;}
    @AuraEnabled public String format {get;set;}

    public SolutionFinderComparisonProperty(Solution_Finder_Comparison_Property__mdt record) {
        this.name = record.DeveloperName;
        this.label = record.MasterLabel;
        this.title = record.Title__c;
        this.dataType = record.Data_Type__c;
        this.decimalPlaces = record.Decimal_Places__c;
        this.initFormat();
    }

    private void initFormat() {
        this.format = '0.0';
    }

    @AuraEnabled
    public static Id saveComparisonProperty(String namespace, String name, String title, String dataType, Decimal decimalPlaces){

        String masterLabel;
        if (title == null) {
            return null;
        } else {
            masterLabel = title.length() > 40 ? title.substring(0, 40) : title;
        }

        if (name == null) {
            name = namespace + '_' + SolutionFinderIndex.getNextName(SolutionFinderConstants.COMPARISON_PROPERTY);
        }

        MetadataRequest request = new MetadataRequest();
        request.init('Solution_Finder_Comparison_Property__mdt', name, masterLabel);
        request.addProperty('Namespace__c', namespace);
        request.addProperty('Title__c', title);
        request.addProperty('Data_Type__c', dataType);
        request.addProperty('Decimal_Places__c', decimalPlaces);
        return request.execute();
    }
}