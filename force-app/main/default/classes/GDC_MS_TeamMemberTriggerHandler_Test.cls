@isTest(SeeAllData=true)
public class GDC_MS_TeamMemberTriggerHandler_Test {
    /*@testSetup static void setup() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='CSG Base Profile'];

        User u = new User(Alias = 'standt', Email='testTemp@testTemp.com',
                          EmailEncodingKey='UTF-8', LastName='testTemp', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testTemp@testTemp.com' , Title = 'Director');
        insert u;


        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = u.Title;
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = u.name;
        temp.gdc_ms_MappedUser__c = u.Id;
        temp.gdc_ms_isActive__c = true;

        insert temp;

    }*/

    static testMethod void testtrigger(){

        gdc_ms_TeamMember__c teamMember = [Select Id,name from gdc_ms_TeamMember__c LIMIT 1];
        teamMember.gdc_ms_isActive__c = false;
        Test.startTest();
        update teamMember;
        Test.stopTest();
    }

}