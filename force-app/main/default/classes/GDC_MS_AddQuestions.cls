public with sharing class GDC_MS_AddQuestions {
    @AuraEnabled
    public static Picklists getPicklistValues() {
        List<PicklistOptions> lstTypePicklistValues = new List<PicklistOptions>();
        List<Schema.PicklistEntry> lstPLE = gdc_ms_Question__c.gdc_ms_Type__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry objPLE: lstPLE) {
            if(objPLE.isActive()) {
                lstTypePicklistValues.add(new PicklistOptions(objPLE.getLabel(), objPLE.getValue()));
            }
        }
        
        List<PicklistOptions> lstCategories = new List<PicklistOptions>();
        List<gdc_ms_FormCategoryMapping__mdt> lstFCM = [SELECT Id,gdc_ms_Category__c FROM gdc_ms_FormCategoryMapping__mdt];
        for(gdc_ms_FormCategoryMapping__mdt objFCM : lstFCM) {
            if(String.isNotBlank(objFCM.gdc_ms_Category__c)) {
                lstCategories.add(new PicklistOptions(objFCM.gdc_ms_Category__c, objFCM.gdc_ms_Category__c));
            }
        }
        Picklists objpicklists = new Picklists(lstTypePicklistValues,lstCategories);
        return objpicklists;
    }
    
    @AuraEnabled
    public static List<gdc_ms_Question__c> getQuestions(String strCategory) {
        List<gdc_ms_Question__c> lstQuestions = [SELECT Id, gdc_ms_Question__c, gdc_ms_Required__c, gdc_ms_Type__c, gdc_ms_Options__c, gdc_ms_Is_Active__c,gdc_ms_Order__c FROM gdc_ms_Question__c 
                                          			WHERE gdc_ms_Category__c =:strCategory ORDER BY  /*gdc_ms_Is_Active__c desc, */gdc_ms_Order__c];
        return lstQuestions;
     }
    
    @AuraEnabled
    public static String getObjectName(String strCategory) {
        String strObjectName = '';
        gdc_ms_FormCategoryMapping__mdt objFCM = [SELECT Id, DeveloperName, gdc_ms_Category__c FROM gdc_ms_FormCategoryMapping__mdt WHERE gdc_ms_Category__c=:strCategory LIMIT 1];
        strObjectName  = objFCM.DeveloperName;
        return strObjectName;
     }
    
    public class PicklistOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    public class Picklists {
        @AuraEnabled public List<PicklistOptions> typeOptions;
        @AuraEnabled public List<PicklistOptions> categoryOptions;
        public Picklists(List<PicklistOptions> typeOptions, List<PicklistOptions> categoryOptions) {
            this.typeOptions = typeOptions;
            this.categoryOptions = categoryOptions;
        }
    }
}