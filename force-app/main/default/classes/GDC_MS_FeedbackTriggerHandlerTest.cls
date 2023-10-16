@isTest
public class GDC_MS_FeedbackTriggerHandlerTest {
    @testSetup static void setup() {
         Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;
        
        gdc_ms_TeamMember__c  teamMember = new gdc_ms_TeamMember__c(
            gdc_ms_isActive__c =True,
            Name='TestMember',
            gdc_ms_Summary__c ='TestSummary',
            gdc_ms_Designation__c='TestD',
        	gdc_ms_MappedUser__c = UserInfo.getUserId());
        insert teamMember;
        gdc_ms_ReusableAsset__c  asst = new gdc_ms_ReusableAsset__c();
        asst.gdc_ms_Title__c ='Test Asset';
        asst.gdc_ms_Benefits__c ='Other';
        asst.gdc_ms_CloudCompetency__c= 'Core';
        asst.gdc_ms_IdeaClassification__c='Technical';
        //asst.gdc_ms_Proposed_By__c=teamMember.id;
        asst.gdc_ms_Proposed_By_User__c = u.Id;
        asst.gdc_ms_IntendedDomainIndustries__c = 'Healthcare';
        insert asst;
        
        GDC_MS_Ignore_Status__c customSetting=new GDC_MS_Ignore_Status__c(
            Name='Ignore Asset Status',
            GDC_MS_Status_Values__c='Parked,Rejected,Ready for Team Demo,Delivered');
        insert customSetting;
        
    }
    
    @isTest static void testInsertScenario() {
      	list<gdc_ms_ReusableAsset__c> asst = [SELECT Id from gdc_ms_ReusableAsset__c];
        List<gdc_ms_Feedback__c> feedBackList = new List<gdc_ms_Feedback__c>();
        integer RECORD_COUNT = 100;
        for(Integer i = 1; i < RECORD_COUNT; i++){
            gdc_ms_Feedback__c d = new gdc_ms_Feedback__c();
            d.gdc_ms_AssetUsageRating__c = '3';
            d.gdc_ms_AssetSuggestion__c = 'Asset Suggestion Test'+string.valueOf(i);
            d.gdc_ms_AssetTitle__c =asst[0].Id;
            feedBackList.add(d);
        }
        Test.startTest();
        insert feedBackList;
        System.assertEquals(feedBackList.size(),99);
        list<gdc_ms_ReusableAsset__c> asst1 = [SELECT Id,gdc_ms_Asset_Rating__c  from gdc_ms_ReusableAsset__c];
        System.assertEquals(asst1[0].gdc_ms_Asset_Rating__c,3);
        Test.stopTest();
        
    }
     @isTest static void testUpdateScenario() {
      	list<gdc_ms_ReusableAsset__c> asst = [SELECT Id from gdc_ms_ReusableAsset__c];
        List<gdc_ms_Feedback__c> feedBackList = new List<gdc_ms_Feedback__c>();
        integer RECORD_COUNT = 100;
        for(Integer i = 1; i < RECORD_COUNT; i++){
            gdc_ms_Feedback__c d = new gdc_ms_Feedback__c();
            d.gdc_ms_AssetUsageRating__c = '3';
            d.gdc_ms_AssetSuggestion__c = 'Asset Suggestion Test'+string.valueOf(i);
            d.gdc_ms_AssetTitle__c =asst[0].Id;
            feedBackList.add(d);
        }
        insert feedBackList;
        Test.startTest();
       	feedBackList[0].gdc_ms_AssetUsageRating__c='4';
        UPDATE feedBackList;
        System.assertEquals(feedBackList.size(),99);
        Test.stopTest();
        
    }
    @isTest static void testDeleteScenario() {
      	list<gdc_ms_ReusableAsset__c> asst = [SELECT Id from gdc_ms_ReusableAsset__c];
        List<gdc_ms_Feedback__c> feedBackList = new List<gdc_ms_Feedback__c>();
        integer RECORD_COUNT = 100;
        for(Integer i = 1; i < RECORD_COUNT; i++){
            gdc_ms_Feedback__c d = new gdc_ms_Feedback__c();
            d.gdc_ms_AssetUsageRating__c = '3';
            d.gdc_ms_AssetSuggestion__c = 'Asset Suggestion Test'+string.valueOf(i);
            d.gdc_ms_AssetTitle__c =asst[0].Id;
            feedBackList.add(d);
        }
        insert feedBackList;
        Test.startTest();
       	DELETE feedBackList;
        feedBackList = [SELECT id FROM gdc_ms_Feedback__c];
        System.assertEquals(feedBackList.size(),0);
        Test.stopTest();
        
    }
}