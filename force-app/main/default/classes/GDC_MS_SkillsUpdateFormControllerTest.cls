/****************************
* Created By - Kushagra, Sehrab and Vibhor
* Purpose - This is a test class for GDC_MS_SkillsUpdateFormController class.
****************************/

@isTest
public with sharing class GDC_MS_SkillsUpdateFormControllerTest {
    @testSetup static void setup() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='tempmember@tempmember.com', 
                          EmailEncodingKey='UTF-8', LastName='tempmembertwo', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tempmembertwo@tempmembertwo.com');
        insert u;
        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = 'Technical Consultant';
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = 'Team Member Two';
        temp.gdc_ms_MappedUser__c = u.Id;
        insert temp;
        
    }
    
    static testMethod void testGetTeamMemberSkillSet() {
        User u = [Select Id from User WHERE LastName='tempmembertwo' LIMIT 1];
        String userId = u.Id;
        test.startTest();
        GDC_MS_SkillsUpdateFormController.SkillSet temp = GDC_MS_SkillsUpdateFormController.getTeamMemberSkillSet(userId);
        test.stopTest();
    }
    
    static testMethod void testGetTeamMemberSkillSetException() {
        User u = [Select Id,(Select Id from gdc_Team_Members__r) from User WHERE LastName='tempmembertwo' LIMIT 1];
        gdc_ms_TeamMember__c tm = new gdc_ms_TeamMember__c();
        tm.Id = u.gdc_Team_Members__r[0].Id;
        delete tm;
        String userId = u.Id;
        test.startTest();
        try{
        GDC_MS_SkillsUpdateFormController.SkillSet temp = GDC_MS_SkillsUpdateFormController.getTeamMemberSkillSet(userId);
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
            
        test.stopTest();
    }
}