/****************************
* Created By - Kushagra, Sehrab and Vibhor
* Purpose - This is a test class for GDC_MS_AutomateMSTeamMember_Batch and GDC_MS_UpdateMSTeamMemberManager classes.
****************************/

@isTest
public class GDC_MS_TeamMemberBatchTest {
    
    @testSetup static void setup() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
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
        
        User u2 = new User(Alias = 'standt', Email='tempmember@tempmember.com', 
                          EmailEncodingKey='UTF-8', LastName='tempmember', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tempmember@tempmember.com', Title = 'Delivery Manager');
        u2.Mgmt_Chain_Hierarchy_Level_06__c = u.Id;
        u2.ManagerId = u.Id;
        insert u2;
        
        /*temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = 'Technical Consultant';
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = 'Team Member';
        temp.gdc_ms_MappedUser__c = u2.Id;
        insert temp;*/
        
    }
    
    static testMethod void testBatch() {
        User u = [Select Id from USER where LastName = 'temproot' LIMIT 1];
        GDC_MS_RootTeamMember__c  mc = new GDC_MS_RootTeamMember__c();
        mc.gdc_ms_RootTeamMemberID__c = u.Id;
        mc.gdc_ms_RootTeamMemberFieldName__c = 'Mgmt_Chain_Hierarchy_Level_06__c';
        insert mc;
        test.startTest();
        Database.executeBatch(new GDC_MS_AutomateMSTeamMember_Batch());
        test.stopTest();
        
    }
    
    
    static testMethod void testBatch1() {
        User u = [Select Id from USER where LastName = 'temproot' LIMIT 1];
        GDC_MS_RootTeamMember__c  mc = new GDC_MS_RootTeamMember__c();
        mc.gdc_ms_RootTeamMemberID__c = u.Id;
        mc.gdc_ms_RootTeamMemberFieldName__c = 'Mgmt_Chain_Hierarchy_Level_06__c';
        mc.gdc_ms_LastRunTimestamp__c = DateTime.now().addDays(-1);
        insert mc;
        test.startTest();
        Database.executeBatch(new GDC_MS_AutomateMSTeamMember_Batch());
        test.stopTest();
        
    }
}