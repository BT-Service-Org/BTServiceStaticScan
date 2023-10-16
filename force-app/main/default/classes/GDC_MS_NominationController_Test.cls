@isTest
public class GDC_MS_NominationController_Test {
    @testSetup static void methodName() {
        
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
        nominationsLst.add(nominations);
        
        gdc_ms_Nomination__c nominations2 = new gdc_ms_Nomination__c ();
        nominations2.gdc_ms_AwardCategory__c = 'Trailblazer Award';
        nominations2.gdc_ms_Nominee__c = temp.Id;
        nominations2.gdc_ms_Winner__c = true;
        nominations2.gdc_ms_Quarter__c = 'Q4';
        nominations2.gdc_ms_Year__c = '2023';
        nominationsLst.add(nominations2);
        insert nominationsLst;
        
        gdc_ms_WallOfFame__c wallOfFame = new gdc_ms_WallOfFame__c();
        wallOfFame.gdc_ms_TeamMember__c = temp.Id;
        wallOfFame.gdc_ms_Quarter__c = 'Q4';
        wallOfFame.gdc_ms_Year__c = '2023';
        insert wallOfFame;

	}
	@isTest
    public static void getNominationTest(){
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id from GDC_MS_RewardsAndRecognition__c];
        list<gdc_ms_Nomination__c> nominationsLst = [Select Id from gdc_ms_Nomination__c];
        Test.startTest();
        GDC_MS_NominationController.getNominations();
        Test.stopTest();
    }
    @isTest
    public static void updateNominationTest(){
        list<string> recordIds = new list<string>();
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id from GDC_MS_RewardsAndRecognition__c];
        for (gdc_ms_Nomination__c nominations : [Select Id from gdc_ms_Nomination__c where gdc_ms_Winner__c = false]){
            recordIds.add(nominations.Id);
        }
        Test.startTest();
        GDC_MS_NominationController.updateWinner(recordIds);
        Test.stopTest();
    }
    @isTest
    public static void getWinnerListTest(){
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id from GDC_MS_RewardsAndRecognition__c];
        list<gdc_ms_Nomination__c> nominationsLst = [Select Id from gdc_ms_Nomination__c];
        Test.startTest();
        GDC_MS_NominationController.getWinners();
        Test.stopTest();
    }
    @isTest
    public static void updateWinnerTest(){
        list<string> recordIds = new list<string>();
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id from GDC_MS_RewardsAndRecognition__c];
        for (gdc_ms_Nomination__c nominations : [Select Id from gdc_ms_Nomination__c where gdc_ms_Winner__c = true]){
            recordIds.add(nominations.Id);
        }
        Test.startTest();
        GDC_MS_NominationController.removeWinner(recordIds);
        Test.stopTest();
    }
    @isTest
    public static void getNominationsRecordsTest(){
        List<GDC_MS_RewardsAndRecognition__c> quarter = [Select Id from GDC_MS_RewardsAndRecognition__c];
        list<gdc_ms_Nomination__c> nominationsLst = [Select Id from gdc_ms_Nomination__c];
        Test.startTest();
        GDC_MS_NominationController.getNominationsRecords('Trailblazer Award','true');
        Test.stopTest();
    }
}