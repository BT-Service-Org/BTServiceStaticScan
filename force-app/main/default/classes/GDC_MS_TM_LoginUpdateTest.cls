@isTest
public without sharing class GDC_MS_TM_LoginUpdateTest {

    @IsTest
    static void testLoginDate(){
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Global Delivery Center Profile'];

        User u = new User(Alias = 'standt', Email='temproot@temproot.com',
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot@temproot.com' , Title = 'Director');
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

        Test.startTest();
        System.runAs(u){
            GDC_MS_TM_LoginUpdate.updateTeamMemberRecord();
        }
        Test.stopTest();

    }

    @IsTest
    static void exTestMethod(){

        Test.startTest();
        try {
            GDC_MS_TM_LoginUpdate.updateTeamMemberRecord();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        Test.stopTest();

    }
}