public with sharing class CustomMethodEditController {

    /**This is get current status of the method */
    @AuraEnabled(cacheable=true)
    public static String getMethodStatus(String recordId) {
        return [Select Id, Status__c from Method__c where Id =:recordId]?.Status__c;
    }

    /**This is for Grouping records */
    @AuraEnabled(cacheable=true)
    public static String getGroupingIds(String recordId) {
        String groupingRecords = '';
        for(Method_by_Grouping__c grouings :[select Id,Grouping__c,Method__c from Method_by_Grouping__c where Method__c= :recordId]) {
            groupingRecords += grouings.Grouping__c != null ? grouings.Grouping__c + ';' : '';
        }
        return groupingRecords;
    }

    /**This is for Stage records */
    @AuraEnabled(cacheable=true)
    public static String getStageIds(String recordId) {
        String stageRecords = '';
        for(Method_with_Stage__c stage :[select Id,Stage__c,Method__c from Method_with_Stage__c  where Method__c= :recordId]) {
            stageRecords += stage.Stage__c != null ? stage.Stage__c + ';' : '';
        }
        return stageRecords;
    }

    /**This is for Industry records */
    @AuraEnabled(cacheable=true)
    public static String getIndustryIds(String recordId) {
        String industryRecords = '';
        for(Method_Industry__c industry :[select Id,Industry__c,Method__c from Method_Industry__c  where Method__c= :recordId]) {
            industryRecords += industry.Industry__c != null ? industry.Industry__c + ';' : '';
        }
        return industryRecords;
    }

    /**This is for Service Product records i.e. Product Offering records with RT:Service_Offering */
    @AuraEnabled(cacheable=true)
    public static String getServiceProductIds(String recordId) {
        String serviceProductIds = '';
        for(Method_Ownership_by_Product__c serProduct :[select Id,Product__c,Method__c from Method_Ownership_by_Product__c  where Method__c= :recordId]) {
            serviceProductIds += serProduct.Product__c != null ? serProduct.Product__c + ';' : '';
        }
        return serviceProductIds;
    }

    /**This is for Product records i.e. Product Offering records other than RT:Service_Offering */
    @AuraEnabled(cacheable=true)
    public static String getProductIds(String recordId) {
        String productIds = '';
        for(Method_by_Product__c product :[select Id,Product__c,Method__c from Method_by_Product__c  where Method__c= :recordId]) {
            productIds += product.Product__c != null ? product.Product__c + ';' : '';
        }
        return productIds;
    }
 
}