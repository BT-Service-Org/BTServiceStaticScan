@isTest
public class GDC_MS_PublishWinnerController_Test {
    @TestSetup
    static void testDataSetup(){
         
        GDC_MS_RewardsAndRecognition__c quarter = new GDC_MS_RewardsAndRecognition__c();
        quarter.gdc_ms_Quarter__c ='Q4';
        quarter.gdc_ms_Year__c = '2023';
        quarter.gdc_ms_QuarterStartDate__c =date.parse('08/03/2023');
        quarter.gdc_ms_QuarterEndDate__c =date.parse('08/31/2023');
        insert quarter;

        gdc_ms_TeamMember__c temp = new gdc_ms_TeamMember__c ();
        temp.gdc_ms_Designation__c = 'Technical Consultant';
        temp.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp.gdc_ms_Summary__c = 'aaaa';
        temp.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp.Name = 'Team Member';
        insert temp;

        list<gdc_ms_Nomination__c> nominationsLst = new list<gdc_ms_Nomination__c>();
        gdc_ms_Nomination__c nominations = new gdc_ms_Nomination__c ();
        nominations.gdc_ms_AwardCategory__c = 'Trailblazer Award';
        nominations.gdc_ms_Nominee__c = temp.Id;
        nominations.gdc_ms_Quarter__c = 'Q4';
        nominations.gdc_ms_Year__c = '2023';
        nominations.Publish_On_WallOfFame__c = true;
        nominationsLst.add(nominations);
        
        gdc_ms_Nomination__c nominations2 = new gdc_ms_Nomination__c ();
        nominations2.gdc_ms_AwardCategory__c = 'Trailblazer Award';
        nominations2.gdc_ms_Nominee__c = temp.Id;
        nominations2.gdc_ms_Winner__c = true;
        nominations2.gdc_ms_Quarter__c = 'Q4';
        nominations2.gdc_ms_Year__c = '2023';
        nominations2.Publish_On_WallOfFame__c = false;

        nominationsLst.add(nominations2);
        insert nominationsLst;
        
    }
    static testMethod void getpublishTheWinnersTest(){
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id,gdc_ms_QuarterEndDate__c from GDC_MS_RewardsAndRecognition__c];
        quarter[0].gdc_ms_QuarterEndDate__c  =date.parse('08/10/2023');
        update quarter;
        test.startTest();
        String result = GDC_MS_PublishWinnerController.publishTheWinners();
        System.assertEquals('', result,'upsert successful');
        test.stopTest();
    }
    
}