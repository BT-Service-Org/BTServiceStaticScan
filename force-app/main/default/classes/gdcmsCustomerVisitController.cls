public without sharing class gdcmsCustomerVisitController {
    
    @AuraEnabled(cacheable=true)
    public static List<gdc_ms_Customer_Visit__c> getData(){
                
        return [SELECT Id, gdc_ms_Customer_Logo__c, gdc_ms_Designation_of_Visitor__c, gdc_ms_Key_outcomes__c, gdc_ms_Name_of_Customer__c, 
                	   gdc_ms_Name_of_visitor__c, gdc_ms_Participants_from_SF__c, gdc_ms_Photos_of_visitor__c, gdc_ms_Quotes_from_Client__c, 
                	   gdc_ms_Quotes_from_SF__c,gdc_ms_SF_Partner_Designation__c, gdc_ms_SF_Partner_Name__c, gdc_ms_SF_Partner_Photo__c, gdc_ms_Video__c 
                FROM gdc_ms_Customer_Visit__c 
                WHERE gdc_ms_Is_Visible_on_Carousel__c = true LIMIT 4];         
    }
}