@isTest
public class GDC_MS_DisplayWallOfFame_Test {
    
    static testmethod void getWallOfFameRecordsTest(){
        
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='testTemp@testTemp.com', 
                          EmailEncodingKey='UTF-8', LastName='testTemp', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testTemp@testTemp.com' , Title = 'Director');
        insert u;
        
        GDC_MS_RewardsAndRecognition__c quarter = new GDC_MS_RewardsAndRecognition__c();
        quarter.gdc_ms_Quarter__c ='Q4';
        quarter.gdc_ms_Year__c = '2023';
        quarter.gdc_ms_QuarterStartDate__c =date.parse('08/03/2023');
        quarter.gdc_ms_QuarterEndDate__c =date.parse('03/31/2023');
        insert quarter;
        
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
        
        gdc_ms_Nomination__c nomination = new gdc_ms_Nomination__c();
        nomination.Publish_On_WallOfFame__c =true;
        nomination.gdc_ms_Quarter__c = 'Q4';
        nomination.gdc_ms_AwardCategory__c = 'Achievers Award';
        nomination.gdc_ms_Nominee__c = temp.Id;
        insert nomination;
        
        test.startTest();
         List<gdc_ms_Nomination__c> listOfRecords =  GDC_MS_DisplayWallOfFame.getWallOfFameRecords('Achievers Award');
        System.assert(listOfRecords.size() >=1);
        test.stopTest();
    }
    
}