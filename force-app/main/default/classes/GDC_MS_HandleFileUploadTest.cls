@isTest
public class GDC_MS_HandleFileUploadTest {
    @isTest
    public static void handleFileUploadTestMethod1(){
        gdc_ms_Engagement__c st= new gdc_ms_Engagement__c(Name= 'Test Record');
        insert st;
        gdc_ms_Engagement__c st1= [Select Id, gdc_ms_CompanyLogo__c from gdc_ms_Engagement__c limit 1];
        system.assertEquals(st.gdc_ms_CompanyLogo__c, Null);
        
        GDC_MS_HandleFileUpload.saveDocument(st.Id, 'dummy.png', 'dummy data' ,'image/png');
        st1= [Select Id, gdc_ms_CompanyLogo__c from gdc_ms_Engagement__c limit 1];
        system.assertNotEquals(st1.gdc_ms_CompanyLogo__c, Null);
    }
    
    @isTest
    public static void handleFileUploadTestMethod2() {
        gdc_ms_TeamMember__c tm = new gdc_ms_TeamMember__c(Name = 'Test Record', gdc_ms_Designation__c = 'Technical Consultant');
        insert tm;
        gdc_ms_TeamMember__c tm1 = [Select Id, gdc_ms_ProfilePhoto__c from gdc_ms_TeamMember__c limit 1];
        system.assertEquals(tm.gdc_ms_ProfilePhoto__c, Null); 
        
        GDC_MS_HandleFileUpload.saveDocument(tm.Id, 'dummy.png', 'dummy data' ,'image/png');
        tm1 = [Select Id, gdc_ms_ProfilePhoto__c from gdc_ms_TeamMember__c limit 1];
        system.assertNotEquals(tm1.gdc_ms_ProfilePhoto__c, Null);
    }
}