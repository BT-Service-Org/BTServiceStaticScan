@isTest
public class GDC_MS_SiteContentUtilTest {
    @testSetup static void setup() {
        gdc_ms_Site_Content_Page__c SiteContentPage = new gdc_ms_Site_Content_Page__c();
        SiteContentPage.Name                        = 'Test Site Content Page';
        SiteContentPage.gdc_ms_ContentId__c         = '*$12345*$';
        insert SiteContentPage;
        gdc_ms_Site_Content__c SiteContent = new gdc_ms_Site_Content__c();
        SiteContent.gdc_ms_ParentId__c = SiteContentPage.Id;
        SiteContent.gdc_ms_Sort_Number__c = 1;
        SiteContent.gdc_ms_Body_Content__c = 'Test body';
        insert SiteContent;
        gdc_ms_Site_Content_Placeholder__c placeHolder = new gdc_ms_Site_Content_Placeholder__c();
        placeHolder.gdc_ms_Site_Content__c = SiteContent.Id;
        placeHolder.gdc_ms_Placeholder_Key__c = 'TestKey';
        placeHolder.gdc_ms_Placeholder_Value__c = 'TestValue';
        insert placeHolder;
    }
    static testMethod void getSitecontentTest(){
        test.startTest();
        String Key = [SELECT Id,gdc_ms_ContentId__c from gdc_ms_Site_Content_Page__c].gdc_ms_ContentId__c;
        List<gdc_ms_Site_Content__c> SiteContent = GDC_MS_SiteContentUtil.getSitecontent(Key);
        System.assertEquals(1, SiteContent.Size(),'Site Content Not Found');
        SiteContent = GDC_MS_SiteContentUtil.getSitecontent('');
        test.stopTest();
    }
    static testMethod void fetchplaceholderValuesTest(){
        test.startTest();
        List<gdc_ms_Site_Content__c> SiteContent = [SELECT Id from gdc_ms_Site_Content__c];
        List< gdc_ms_Site_Content_Placeholder__c> placeHolderContent = GDC_MS_SiteContentUtil.fetchplaceholderValues(SiteContent);
        System.assertEquals(1, placeHolderContent.Size(),'placeholder Not Found');
        test.stopTest();
    }
}