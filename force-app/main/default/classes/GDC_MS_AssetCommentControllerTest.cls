@isTest(seeAllData=false)
public with sharing class GDC_MS_AssetCommentControllerTest {
    @TestSetup
    static void makeData(){
         Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot12@temproot.com' , Title = 'Director');
        insert u;
        
        
        User mappedUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        gdc_ms_TeamMember__c teamMember = new gdc_ms_TeamMember__c ();
        teamMember.gdc_ms_Designation__c = 'Technical Consultant';
        teamMember.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        teamMember.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        teamMember.gdc_ms_Summary__c = 'aaaa';
        teamMember.gdc_ms_VerticalExpertise__c = 'aaaa';
        teamMember.Name = 'Team Member';
        teamMember.gdc_ms_MappedUser__c = mappedUser.Id;
        INSERT teamMember;
        
        List<gdc_ms_ReusableAsset__c> listAssets = new List<gdc_ms_ReusableAsset__c>();
        gdc_ms_ReusableAsset__c asset = new gdc_ms_ReusableAsset__c();
        asset.gdc_ms_Title__c = 'Title';
        asset.gdc_ms_Description__c = 'Description';
        asset.gdc_ms_Benefits__c = 'Time Saved';
        asset.gdc_ms_CloudCompetency__c = 'Marketing' ;
        asset.gdc_ms_IdeaClassification__c = 'Technical';
        asset.gdc_ms_ProblemSolvedByThisAsset__c = 'Test';
        //asset.gdc_ms_Proposed_By__c = teamMember.Id;
        asset.gdc_ms_Proposed_By_User__c = u.id;
        asset.gdc_ms_IntendedDomainIndustries__c = 'Healthcare';
        listAssets.add(asset);
        //INSERT listAssets;
        insert asset;
        
        gdc_ms_AssetMember__c member = new gdc_ms_AssetMember__c();
        member.gdc_ms_TeamMember__c = teamMember.Id;
        member.gdc_ms_Role__c = 'QA';
        member.gdc_ms_ReusableAsset__c = asset.Id;//listAssets[0].Id;
        INSERT member;
        
        gdc_ms_Reusable_Asset_Comments__c comment = new gdc_ms_Reusable_Asset_Comments__c();
        comment.gdc_ms_Comment_Body__c = 'Comment Body';
        comment.gdc_ms_Reusable_Asset__c = asset.Id;//listAssets[0].Id;
        comment.gdc_ms_Recipient_Email_Ids__c = 'test@test.com';
        INSERT comment;
    }
    
    @IsTest
    public static void positiveTestMethod(){
        
        gdc_ms_ReusableAsset__c asset = [SELECT Id FROM gdc_ms_ReusableAsset__c LIMIT 1];
        
        GDC_MS_AssetCommentController.CustomWrapper wrapper = new GDC_MS_AssetCommentController.CustomWrapper();
        wrapper.commentBody = 'Test Body';
        wrapper.assetId = asset.Id;
        wrapper.recipientEmailIds = 'test1@test.com';
        
        GDC_MS_AssetCommentController.createComment(wrapper);
        
        List<gdc_ms_Reusable_Asset_Comments__c> commentList = GDC_MS_AssetCommentController.getAllComments(asset.Id);
        if(commentList.size()>0){
            System.assertEquals(2, commentList.size(), 'The expected number of comments are not equal');
        }
        
        GDC_MS_AssetCommentController.updateComment(commentList[0].Id, 'Updated Description');
        GDC_MS_AssetCommentController.deleteComment(commentList[0].Id);
        GDC_MS_AssetCommentController.getAssetMembers(asset.Id);
    }
    
    @IsTest
    public static void negativeTestMethod(){
        
        Boolean exceptionOccurred = false;
        
        gdc_ms_ReusableAsset__c asset = [SELECT Id FROM gdc_ms_ReusableAsset__c LIMIT 1];
        
        GDC_MS_AssetCommentController.CustomWrapper wrapper = new GDC_MS_AssetCommentController.CustomWrapper();
        wrapper.commentBody = 'Test Body';
        wrapper.assetId = asset.Id;
        wrapper.recipientEmailIds = 'test1@test.com';
        
        GDC_MS_AssetCommentController.createComment(wrapper);
        
        List<gdc_ms_Reusable_Asset_Comments__c> commentList = GDC_MS_AssetCommentController.getAllComments(asset.Id);
        if(commentList.size()>0){
            System.assertEquals(2, commentList.size(), 'The expected number of comments are not equal');
        }
        
        try{
            GDC_MS_AssetCommentController.updateComment('dummy', 'Updated Description');
            GDC_MS_AssetCommentController.deleteComment('dummy');
            GDC_MS_AssetCommentController.getAssetMembers('dummy');
        }catch(Exception e){
            exceptionOccurred = true;
        }
        System.assertEquals(true,exceptionOccurred, 'Exception was not thrown');
        
    }
    
}