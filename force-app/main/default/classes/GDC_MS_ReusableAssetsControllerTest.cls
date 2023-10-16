@isTest
public class GDC_MS_ReusableAssetsControllerTest {
    @testSetup
    static void createData() {
        GDC_MS_Ignore_Status__c customSetting=new GDC_MS_Ignore_Status__c(
            Name='Ignore Asset Status',
            GDC_MS_Status_Values__c='Parked,Rejected,Ready for Team Demo,Delivered');
        insert customSetting;
        
        gdc_ms_TeamMember__c teamMember1 = new gdc_ms_TeamMember__c();
        teamMember1.gdc_ms_isActive__c = true;
        teamMember1.Name = 'Test Member1';
        teamMember1.gdc_ms_Designation__c = 'Technical Consultant';
        teamMember1.gdc_ms_MappedUser__c = UserInfo.getUserId();
        insert teamMember1;
        
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
          Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;

        List<gdc_ms_ReusableAsset__c> listAssets = new List<gdc_ms_ReusableAsset__c>();
        gdc_ms_ReusableAsset__c asset = new gdc_ms_ReusableAsset__c();
        asset.gdc_ms_Title__c = 'Test Asset 1';
        asset.gdc_ms_Description__c = 'Asset test description';
        asset.gdc_ms_Status__c = 'Ideation';
        asset.gdc_ms_Benefits__c = 'Time saved;Cost saved';
        asset.gdc_ms_CloudCompetency__c = 'Core';
        asset.gdc_ms_DemoLink__c = 'https://drive.google.com/file/d/demo';
        asset.gdc_ms_RepositoryLink__c = 'https://git.soma.salesforce.com/repo';
        asset.gdc_ms_DesignLink__c = 'https://salesforce.quip.com/design';
        //asset.gdc_ms_Proposed_By__c = teamMember1.Id;
        asset.gdc_ms_Proposed_By_User__c = u.id;
        asset.gdc_ms_IdeaClassification__c = 'Technical';
        asset.gdc_ms_ProblemSolvedByThisAsset__c = 'Test Solution';
        asset.gdc_ms_IntendedDomainIndustries__c ='Healthcare';
        listAssets.add(asset);
        gdc_ms_ReusableAsset__c asset1 = new gdc_ms_ReusableAsset__c();
        asset1.gdc_ms_Title__c = 'Test Asset 2';
        asset1.gdc_ms_Description__c = 'Asset test description';
        asset1.gdc_ms_Status__c = 'Delivered';
        asset1.gdc_ms_Benefits__c = 'Time saved;Cost saved';
        asset1.gdc_ms_CloudCompetency__c = 'Core';
        asset1.gdc_ms_DemoLink__c = 'https://drive.google.com/file/d/demo';
        asset1.gdc_ms_RepositoryLink__c = 'https://git.soma.salesforce.com/repo';
        asset1.gdc_ms_DesignLink__c = 'https://salesforce.quip.com/design';
        //asset1.gdc_ms_Proposed_By__c = teamMember1.Id;
        asset1.gdc_ms_Proposed_By_User__c = u.id;
        asset1.gdc_ms_IdeaClassification__c = 'Technical';
        asset1.gdc_ms_ProblemSolvedByThisAsset__c = 'Test Solution';
        asset1.gdc_ms_IntendedDomainIndustries__c ='Healthcare';
        listAssets.add(asset1);
		

        insert asset;

        gdc_ms_AssetMember__c assetMember1 = new gdc_ms_AssetMember__c();
        assetMember1.gdc_ms_role__c = 'Developer';
        assetMember1.gdc_ms_ReusableAsset__c =asset.Id; //listAssets[0].Id;
        assetMember1.gdc_ms_TeamMember__c = teamMember1.Id;
        insert assetMember1;
        
        
        gdc_ms_Feedback__c feedback = new gdc_ms_Feedback__c();
        feedback.gdc_ms_AssetTitle__c = asset.Id;
        feedback.gdc_ms_Logged_In_User__c = UserInfo.getUserId();
        feedback.gdc_ms_AssetUsageRating__c = '4';
        insert feedback;
        
        
    }

    @isTest
    public static void getAssetDetailsTest(){
        Test.startTest();
        gdc_ms_ReusableAsset__c asset = GDC_MS_ReusableAssetsController.getAssetDetails(null);
        System.assertEquals(null, asset, 'Values should be null for null Id');
        List<gdc_ms_ReusableAsset__c> assetRecords = [SELECT Id FROM gdc_ms_ReusableAsset__c WHERE gdc_ms_Title__c = 'Test Asset 1'];
        asset = GDC_MS_ReusableAssetsController.getAssetDetails(assetRecords.get(0).Id);
        System.assertEquals(1, asset.Asset_Members__r.size(), 'Asset members is not returned correctly');
        System.assertEquals('Asset test description', asset.gdc_ms_Description__c, 'Description is not returned correctly');
        System.assertEquals('Core', asset.gdc_ms_CloudCompetency__c, 'Cloud Competency is not returned correctly');
        Test.stopTest();
    }

    @isTest
    public static void updateAssetMembersTest(){
        Test.startTest();
        List<gdc_ms_AssetMember__c> assetTeamMembers = [SELECT Id, gdc_ms_role__c, gdc_ms_TeamMember__c, gdc_ms_ReusableAsset__c
                                                        FROM gdc_ms_AssetMember__c];
       	assetTeamMembers.get(0).gdc_ms_role__c = 'QA';
        String finalResult = GDC_MS_ReusableAssetsController.updateAssetMembers(assetTeamMembers);
        assetTeamMembers = [SELECT Id, gdc_ms_role__c, gdc_ms_TeamMember__c, gdc_ms_ReusableAsset__c
                            FROM gdc_ms_AssetMember__c];
        System.assertEquals('Records Updated Successfully', finalResult, 'Response not returned correctly');
        System.assertEquals('QA', assetTeamMembers.get(0).gdc_ms_role__c, 'Role is not updated');
        Test.stopTest();
    }

    @isTest
    public static void getAssetTest(){
        Test.startTest();
        GDC_MS_ReusableAssetsController.getNonPublishedAssets();
        GDC_MS_ReusableAssetsController.getPublishedAssets();
        Test.stopTest();
    }
    
    @isTest
    public static void getFeedbackRecordTest(){
        Test.startTest();
        String userId = UserInfo.getUserId();
        gdc_ms_Feedback__c feedback = GDC_MS_ReusableAssetsController.getFeedbackRecord(userId,null);
        System.assertEquals(null, feedback, 'Values should be null for null Id');
        List<gdc_ms_Feedback__c> feedbackRecords = [SELECT Id,gdc_ms_AssetTitle__c,gdc_ms_AssetUsageRating__c
                                                    FROM gdc_ms_Feedback__c];
        feedback = GDC_MS_ReusableAssetsController.getFeedbackRecord(userId,feedbackRecords.get(0).gdc_ms_AssetTitle__c);
        System.assertEquals('4', feedback.gdc_ms_AssetUsageRating__c, 'Rating should be 4');
        Test.stopTest();
    }
}