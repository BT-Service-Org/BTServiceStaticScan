@isTest
private without sharing class GDC_MS_DisplaySuccessStoryControllerTest {

    @isTest
    static void getStoriesTest(){

        List<GDC_MS_DisplaySuccessStoryController.StoryWrapper> wrapperList = new List<GDC_MS_DisplaySuccessStoryController.StoryWrapper>();
        List<gdc_ms_Success_Story_Members__c> successStoryMemberList = new List<gdc_ms_Success_Story_Members__c>();

        gdc_ms_Engagement__c obj = new gdc_ms_Engagement__c();
        obj.Name = 'Test story';
        obj.gdc_ms_EngagementSummary__c = 'Test summary';
        obj.gdc_ms_EngagementTitle__c = 'Test Title';
        obj.gdc_ms_Feedback__c = 'Test Feedback';
        obj.gdc_ms_SolutionComplexity__c = 'Test complexity';
        obj.gdc_ms_BusinessValueDelivered__c = 'Test value devlivered';
        obj.gdc_ms_DisplayonSuccessStories__c = true;
        obj.gdc_ms_Is_Visible_on_Carousel__c = true;
        obj.gdc_ms_CompanyLogo__c='Test';

        insert obj;

        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(Alias = 'standt', Email='temproot12@temproot.com',
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;



        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = u.Title;
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = u.Name;
        temp.gdc_ms_MappedUser__c = u.Id;

        insert temp;

        gdc_ms_Success_Story_Members__c successStoryMember = new gdc_ms_Success_Story_Members__c();
        successStoryMember.gdc_ms_Team_Member__c = temp.Id;
        successStoryMember.gdc_ms_Role__c ='Technical Architect';
        successStoryMember.gdc_ms_Success_Stories__c = obj.Id;
        insert successStoryMember;
        Test.startTest();
        wrapperList = GDC_MS_DisplaySuccessStoryController.getStories();
        successStoryMemberList = GDC_MS_DisplaySuccessStoryController.getStoryMembers(obj.Id);
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(1, successStoryMemberList.size());
    }

    @IsTest
    public static void getpicklistTest(){

        Test.startTest();
        GDC_MS_DisplaySuccessStoryController.getPicklistValues('gdc_ms_Geographies__c');
        GDC_MS_DisplaySuccessStoryController.getActiveSuccessStories();
        Test.stopTest();

    }
}