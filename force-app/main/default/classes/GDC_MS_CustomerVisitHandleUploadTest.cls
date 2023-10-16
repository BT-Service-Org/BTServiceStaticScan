@isTest
public with sharing class GDC_MS_CustomerVisitHandleUploadTest {

    @isTest
    public static void handleFileUploadTestMethod(){
        gdc_ms_Customer_Visit__c cv = new gdc_ms_Customer_Visit__c(Name= 'Test Record');
        insert cv;
        gdc_ms_Customer_Visit__c cv1= [Select Id, gdc_ms_Customer_Logo__c from gdc_ms_Customer_Visit__c limit 1];
        system.assertEquals(cv.gdc_ms_Customer_Logo__c, Null);
        
        GDC_MS_CustomerVisitHandleUpload.saveDocument(cv.Id, 'dummy.png', 'dummy data' ,'Customer Logo');
        
        GDC_MS_CustomerVisitHandleUpload.saveDocument(cv.Id, 'dummy.png', 'dummy data' ,'Photo of Visitor');
        
        GDC_MS_CustomerVisitHandleUpload.saveDocument(cv.Id, 'dummy.png', 'dummy data' ,'Photo of SF Partner');
        
        
        cv1= [Select Id, gdc_ms_Customer_Logo__c, gdc_ms_Photos_of_visitor__c, gdc_ms_SF_Partner_Photo__c from gdc_ms_Customer_Visit__c limit 1];
        system.assertNotEquals(cv1.gdc_ms_Customer_Logo__c, Null);
        system.assertNotEquals(cv1.gdc_ms_Photos_of_visitor__c, Null);
        system.assertNotEquals(cv1.gdc_ms_SF_Partner_Photo__c, Null);
    }

}