/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This is a test class for GDC_MS_ProfileViewController class.
 ****************************/

 @isTest
public class GDC_MS_ProfileViewControllerTest {
	@testSetup static void setup() {
        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = 'Technical Consultant';
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = 'Team Member';
        insert temp;

    }
    
    static testMethod void testGetProfileDetails() {
        List<gdc_ms_TeamMember__c> allGDCMembers = [SELECT id,Name FROM gdc_ms_TeamMember__c LIMIT 1];
        test.startTest();
		GDC_MS_ProfileViewController.Profile temp = GDC_MS_ProfileViewController.getProfileDetails(allGDCMembers[0].Id);
        test.stopTest();
    }
    
    
    static testMethod void testGetSkillData() {
        List<gdc_ms_TeamMember__c> allGDCMembers = [SELECT id,Name FROM gdc_ms_TeamMember__c LIMIT 1];
        test.startTest();
		List<String> temp = GDC_MS_ProfileViewController.getSkillData(allGDCMembers[0].Id,'Salesforce Certificates');
        test.stopTest();
    }
}