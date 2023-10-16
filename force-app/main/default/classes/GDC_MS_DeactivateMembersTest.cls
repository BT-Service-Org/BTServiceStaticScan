@isTest
public with sharing class GDC_MS_DeactivateMembersTest {
    @testSetup static void setupData() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;
        
        User u2 = new User(Alias = 'standt2', Email='temproot124@temproot.com', 
                           EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='temproot124@temproot.com' , Title = 'Director');
        insert u2;
        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = u.Title;
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'Temp 1';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = u.Name;
        temp.gdc_ms_isActive__c = false;
        temp.gdc_ms_MappedUser__c = u.Id;
        insert temp;
        
        gdc_ms_TeamMember__c temp2 = new gdc_ms_TeamMember__c ();
        temp2.gdc_ms_Designation__c = u2.Title;
        temp2.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp2.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp2.gdc_ms_Summary__c = 'Temp 2';
        temp2.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp2.Name = u2.Name;
        temp.gdc_ms_isActive__c = true;
        temp2.gdc_ms_MappedUser__c = u2.Id;
        
        insert temp2;
        GDC_MS_Inactive_Team_Members__c cs = new GDC_MS_Inactive_Team_Members__c (SetupOwnerId = u.Id, gdc_ms_User_Email_Id__c = u.Email);
 		insert cs;
    }
    
    @isTest
    static void getStoriesTest(){
     list<gdc_ms_TeamMember__c> lstRes = [Select id , gdc_ms_isActive__c from gdc_ms_TeamMember__c ORDER BY gdc_ms_isActive__c];
        Test.startTest();
        GDC_MS_DeactivateMembers.fetchUsers();
        GDC_MS_DeactivateMembers.fetchInactiveUsers();
        GDC_MS_DeactivateMembers.idToActivate(new List<ID>{lstRes[0].id});
        GDC_MS_DeactivateMembers.idToDeactivate(new List<ID>{lstRes[1].id});
        Test.stopTest();
        
    }
    
}