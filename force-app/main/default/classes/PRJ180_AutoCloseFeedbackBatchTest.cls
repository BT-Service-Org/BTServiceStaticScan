/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For Testing of PRJ180_AutoCloseFeedbackonInactionBatch.
*/ 
@isTest
public class PRJ180_AutoCloseFeedbackBatchTest {
    @testsetup public static void testDataPrep() {
        List<User> lstnewUsers = new List<User>();
        List<User> lstmanagers = new List<User>();
        Id PrjFeed180RecTypeId = Schema.getGlobalDescribe().get('CSG_Project_Feedback__c').getDescribe().getRecordTypeInfosByName().get('Project 180 Feedback').getRecordTypeId();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User adminUser = [SELECT Id, Name FROM user WHERE profile.name = 'System Administrator' AND isActive=true LIMIT 1];
        // Wihtout this we will get a MixedDML Operation Error becuase we are inserting a contact (inserting users calls USerToContactTrigger which calls UserConactUtil which inserts a contact) and users (setup object) in the same transaction.
        // To avoid that, we are doing a System.runAs call to sepearte out the contexts of execution between inserting a contact and users.
        System.runAs(thisUser) {
            lstnewUsers = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(1, 'CSG Base Profile', true);
            lstmanagers = CSG_Engagement_Feedback_Test_DataFactory.createTestManagers(1, 'Standard User', true);
        }        
        for(User usr : lstnewUsers) {
            usr.Mgmt_Chain_Hierarchy_Level_02__c = lstmanagers[0].Id;
        }
        update lstnewUsers;
        List<Contact> contacts = CSG_Engagement_Feedback_Test_DataFactory.createTestContacts(1, true);        
        List<PA_Onboarding__c> onboardingList = CSG_Engagement_Feedback_Test_DataFactory.createTestOnboardingRecords(contacts, lstnewUsers, true);        	
        List<PA_Onboarding_Project__c> projectsList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjects(onboardingList, true);            
        List<CSG_Project_Feedback__c> feedbackList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjectFeedback(projectsList, true);
        feedbackList[0].PRJ180_Feedback_Subject__c = lstnewUsers[0].Id;
        feedbackList[0].RecordTypeId = PrjFeed180RecTypeId;
        feedbackList[0].PRJ180_Notification__c = 3;
        update feedbackList;
        PRJ180_Feedback_Configuration__c csPRJ180Config = PRJ180_Feedback_Configuration__c.getOrgDefaults();
        //Setting day for auto closure as 0 As it will work only on test records created today
        csPRJ180Config.PRJ180_Days_for_Auto_Closure__c  = 0; 
        insert csPRJ180Config;
       }
    
    @isTest public static void testAutoCloseBatch() {
        test.startTest();
        PRJ180_AutoCloseFeedbackBatch batch = new PRJ180_AutoCloseFeedbackBatch();
        ID batchprocessid = Database.executeBatch(batch);
        test.stopTest();
        List<CSG_Project_Feedback__c> lstEngFeedback = [SELECT Id, CSG_Feedback_Request_Status__c from CSG_Project_Feedback__c];
        System.assertEquals('Abandoned', lstEngFeedback[0].CSG_Feedback_Request_Status__c);
    }
}