@isTest
public with sharing class GDCMS_NominationScreenTest {
    
    @TestSetup
    static void makeData(){
        
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
        
        gdc_ms_TeamMember__c temp1 = new gdc_ms_TeamMember__c ();
        temp1.gdc_ms_Designation__c = u2.Title;
        temp1.gdc_ms_SalesforceCertifications__c = 'Salesforce Certified Administrator;Salesforce Certified Advanced Administrator;Platform App Builder;User Experience Designer;Sales Cloud Consultant;CPQ Specialist;Service Cloud Consultant;Field Service Lightning Consultant;Community Cloud Consultant;Einstein Analytics and Discovery Consultant;Nonprofit Cloud Consultant;Education Cloud Consultant;OmniStudio Consultant;Platform Developer I;Platform Developer II;JavaScript Developer I;Industries CPQ Developer;OmniStudio Developer;B2C Commerce Developer;B2C Commerce Architect;Salesforce Accredited B2B Commerce Administrator;Salesforce Accredited B2B Commerce Developer;Salesforce Data Architecture and Management Designer;Salesforce Sharing and Visibility Designer;Salesforce Identity and Access Management Designer;Integration Architecture Designer;Development Lifecycle and Deployment Designer;Heroku Architecture Designer;Application Architect;System Architect;B2C Solution Architect;Certified Technical Architect;Pardot Specialist;Pardot Consultant;Marketing Cloud Admin;Marketing Cloud Email Specialist';
        temp1.gdc_ms_SkillHighlights__c = 'aaaa\naaaa';
        temp1.gdc_ms_Summary__c = 'aaaa';
        temp1.gdc_ms_VerticalExpertise__c = 'aaaa';
        temp1.Name = u.Name;
        temp1.gdc_ms_MappedUser__c = u2.Id;
        temp1.gdc_ms_Manager__c = temp.Id;
        insert temp1;
        
        GDC_MS_RewardsAndRecognition__c rr = new GDC_MS_RewardsAndRecognition__c();
        rr.gdc_ms_QuarterStartDate__c = Date.today();
        rr.gdc_ms_QuarterEndDate__c = date.today() +2;
        rr.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
        rr.gdc_ms_Year__c = String.valueOf(date.today().year());
        insert rr;
        
        
    }
    
    @IsTest
    static void checkSearch(){
        
        String managerUserId = [SELECT Id FROM User WHERE Username = 'temproot@temproot.com' LIMIT 1].Id;
        
        System.debug('managerUserId :: ' + managerUserId);
        
        String searchTerm = 'temp';
        String newString = '\''+ managerUserId + '\'';
        String filter = 'gdc_ms_Manager__r.gdc_ms_MappedUser__c = ' + newString;
        Test.startTest();
        GDCMS_NominationScreenController.search(searchTerm, 'gdc_ms_TeamMember__c', '');
        GDCMS_NominationScreenController.search('',  'gdc_ms_TeamMember__c', '');
        GDCMS_NominationScreenController.search(searchTerm, 'gdc_ms_TeamMember__c', filter);
        Test.stopTest();
        
    }
    
    @isTest
    static void getRecordDetialsTest() {
        User u = [Select Id From User WHERE UserName='tempmember@tempmember.com' Limit 1];
        
        System.runAs(u) {
            
            List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
            List<gdc_ms_Nomination__c> nList = new List<gdc_ms_Nomination__c> ();
            
            gdc_ms_Nomination__c n = new gdc_ms_Nomination__c();
            n.gdc_ms_AwardCategory__c = 'Trailblazer Award';
            n.gdc_ms_Manager__c = tList[0].Id;
            n.gdc_ms_Nominee__c = tList[1].Id;
            n.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Quarterly Award').getRecordTypeId();
            n.gdc_ms_Year__c = String.valueOf(date.today().year());
            n.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
            insert n;
            
            gdc_ms_Nomination__c n1 = new gdc_ms_Nomination__c();
            n1.gdc_ms_AwardCategory__c = 'Achievers Award';
            n1.gdc_ms_Manager__c = tList[0].Id;
            n1.gdc_ms_Nominee__c = tList[1].Id;
            n1.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
            n1.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
            n1.gdc_ms_Year__c = String.valueOf(date.today().year());
            insert n1;          
            
            GDCMS_NominationScreenController.getRecordDetials();
            try {
                GDCMS_NominationScreenController.getRecordAchevierDetials(n1.Id);
            } catch (exception e) {
                system.debug(e.getMessage());
            }
        }
    }
    @isTest
    static void getRecordDetialsTest1() {
        try {
            GDCMS_NominationScreenController.getRecordDetials();
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    static void createManagerRecordsTest() {
        try {
            
            String q= GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
            GDCMS_NominationScreenController.createManagerRecords(String.valueOf(Date.today()), String.valueOf(Date.today() +2), q);
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    static void saveNominationRecordTest() {
        try {
            User u = [Select Id From User WHERE UserName='tempmember@tempmember.com' Limit 1];
            
            System.runAs(u) {
                
                List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
                gdc_ms_Nomination__c n = new gdc_ms_Nomination__c();
                n.gdc_ms_AwardCategory__c = 'Trailblazer Award';
                n.gdc_ms_Manager__c = tList[0].Id;
                n.gdc_ms_Nominee__c = tList[1].Id;
                n.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Quarterly Award').getRecordTypeId();
                n.gdc_ms_Year__c = String.valueOf(date.today().year());
                n.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
                
                gdc_ms_Nomination__c n1 = new gdc_ms_Nomination__c();
                n1.gdc_ms_AwardCategory__c = 'Achievers Award';
                n1.gdc_ms_Manager__c = tList[0].Id;
                n1.gdc_ms_Nominee__c = tList[1].Id;
                n1.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
                n1.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
                n1.gdc_ms_Year__c = String.valueOf(date.today().year());
                
                
                
                String q= GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
                GDCMS_NominationScreenController.saveNominationRecord(n);
                GDCMS_NominationScreenController.saveNominationRecord(n1);
            }
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
    
    @isTest
    static void saveNominationRecordTest1() {
        try {          
            
            User u = [Select Id From User WHERE UserName='tempmember@tempmember.com' Limit 1];
            
            System.runAs(u) {
                
                List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
                
                gdc_ms_Nomination__c n = new gdc_ms_Nomination__c();
                n.gdc_ms_AwardCategory__c = 'Trailblazer Award';
                n.gdc_ms_Manager__c = tList[0].Id;
                n.gdc_ms_Nominee__c = tList[1].Id;
                n.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Quarterly Award').getRecordTypeId();
                n.gdc_ms_Year__c = String.valueOf(date.today().year());
                n.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
                insert n;
                
                gdc_ms_Nomination__c n1 = new gdc_ms_Nomination__c();
                n1.gdc_ms_AwardCategory__c = 'Achievers Award';
                n1.gdc_ms_Manager__c = tList[0].Id;
                n1.gdc_ms_Nominee__c = tList[1].Id;
                n1.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
                n1.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
                n1.gdc_ms_Year__c = String.valueOf(date.today().year());
                insert n1;    
                
                List<gdc_ms_Nomination__c> nList = [Select id from gdc_ms_Nomination__c];
                nList[0].gdc_ms_CustomerAppreciationHighCSATScore__c ='test';
                nList[1].gdc_ms_CustomerAppreciationHighCSATScore__c ='test';
                
                GDCMS_NominationScreenController.saveNominationRecord(nList[0]);
                GDCMS_NominationScreenController.saveNominationRecord(nList[1]);
            }
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    static void saveNominationRecordTest2() {
        try {
            
            List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
            gdc_ms_Nomination__c n1 = new gdc_ms_Nomination__c();
            n1.gdc_ms_AwardCategory__c = 'Achievers Award';
            n1.gdc_ms_Manager__c = tList[0].Id;
            n1.gdc_ms_Nominee__c = tList[1].Id;
            n1.RecordTypeId = Schema.SObjectType.gdc_ms_Nomination__c.getRecordTypeInfosByName().get('Monthly Award').getRecordTypeId();
            n1.gdc_ms_Quarter__c = GDCMS_NominationScreenController.setCurrentQuarter(String.valueOf(Date.today()), String.valueOf(Date.today() +2));
            n1.gdc_ms_Year__c = String.valueOf(date.today().year());                
            GDCMS_NominationScreenController.saveNominationRecord(n1);
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    static void setCurrentQuarterTest() {
        try {
            GDCMS_NominationScreenController.setCurrentQuarter('2022-11-20', '2022-11-22');
            GDCMS_NominationScreenController.setCurrentQuarter('2022-02-20', '2022-02-22');
            GDCMS_NominationScreenController.setCurrentQuarter('2022-05-20', '2022-05-22');
            GDCMS_NominationScreenController.setCurrentQuarter('2022-08-20', '2022-08-22');
            
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    @isTest
    static void getTeamMemberIdTest() {
        try {
             User u = [Select Id From User WHERE UserName='tempmember@tempmember.com' Limit 1];
            
            System.runAs(u) {
                List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
                GDCMS_NominationScreenController.getTeamMemberId();
            }
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    @isTest
    static void getTeamMembersTest() {
        try {
             User u = [Select Id From User WHERE UserName='tempmember@tempmember.com' Limit 1];
            
            System.runAs(u) {
                List<gdc_ms_TeamMember__c> tList = [Select Id from gdc_ms_TeamMember__c];
                
                gdc_ms_Engagement__c successStory = new gdc_ms_Engagement__c();
                successStory.Name = 'Test';
                successStory.gdc_ms_EngagementSummary__c = 'test';
                insert successStory;

                gdc_ms_Success_Story_Members__c successStoryMembers = new gdc_ms_Success_Story_Members__c();
                successStoryMembers.gdc_ms_Team_Member__c = tList[0].Id;
                successStoryMembers.gdc_ms_Success_Stories__c = successStory.Id;
                successStoryMembers.gdc_ms_Role__c = 'Developer';
                insert successStoryMembers;

                GDCMS_NominationScreenController.getTeamMembers(successStory.Id);
            }
        } catch (exception e) {
            system.debug(e.getMessage());
        }
    }
    
}