public with sharing class SolutionFinderProperty {

    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String title {get;set;}
    @AuraEnabled public String dataType {get;set;}
    @AuraEnabled public String defaultValue {get;set;}
    @AuraEnabled public Boolean displayInPreview {get;set;}

    @AuraEnabled public Boolean displayInput {get;set;}
    @AuraEnabled public Boolean displayTextarea {get;set;}
    
    @AuraEnabled public Boolean displayOnKeyUpInput {get;set;}
    @AuraEnabled public Boolean displayOnChangeInput {get;set;}
    @AuraEnabled public Boolean displayCheckedInput {get;set;}

    public SolutionFinderProperty(Solution_Finder_Property__mdt record) {
        this.name = record.DeveloperName;
        this.label = record.MasterLabel;
        this.title = record.Title__c;
        this.dataType = record.Data_Type__c;
        this.defaultValue = record.Default_Value__c;
        this.displayInPreview = record.Display_in_Preview__c;
        
        this.displayInput = record.Data_Type__c != 'Textarea';
        this.displayTextarea = record.Data_Type__c == 'Textarea';

        this.displayOnChangeInput = record.Data_Type__c == 'Color';
        this.displayCheckedInput = record.Data_Type__c == 'Checkbox';
        this.displayOnKeyUpInput = !this.displayOnChangeInput && !this.displayCheckedInput;
    }
}