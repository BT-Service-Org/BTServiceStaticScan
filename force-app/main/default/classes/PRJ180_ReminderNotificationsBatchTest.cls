/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For Testing of PRJ180_ReminderNotificationsBatch.
*/ 
@isTest
public class PRJ180_ReminderNotificationsBatchTest {
    @testsetup public static void testDataPrep() {
        List<User> lstnewUsers = new List<User>();
        List<User> lstmanagers = new List<User>();
        Id PrjFeed180RecTypeId = Schema.getGlobalDescribe().get('CSG_Project_Feedback__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRJ180_Engagement_Feedback').getRecordTypeId();
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
        update feedbackList;
        PRJ180_Feedback_Configuration__c csPRJ180Config = PRJ180_Feedback_Configuration__c.getOrgDefaults();
        //Setting reminder values as 0 As it will work only on test records created today
        csPRJ180Config.PRJ180_Reminder1__c = 0; 
        csPRJ180Config.PRJ180_Reminder2__c = 0; 
        csPRJ180Config.PRJ180_Reminder3__c = 0; 
        insert csPRJ180Config;
    }
    
    @isTest public static void testReminder1() {
        test.startTest();
        PRJ180_ReminderNotificationsBatch batch = new PRJ180_ReminderNotificationsBatch(1);
        ID batchprocessid = Database.executeBatch(batch);
        test.stopTest();
        List<CSG_Project_Feedback__c> lstEngFeedback = [SELECT Id, PRJ180_Last_Reminder_Sent__c, PRJ180_Notification__c from CSG_Project_Feedback__c];
        System.assert(lstEngFeedback[0].PRJ180_Last_Reminder_Sent__c != null);
        System.assert(lstEngFeedback[0].PRJ180_Notification__c != null);
    }
    
    @isTest public static void testReminder2() {
        test.startTest();
        PRJ180_ReminderNotificationsBatch batch = new PRJ180_ReminderNotificationsBatch(2);
        ID batchprocessid = Database.executeBatch(batch);
        test.stopTest();
        List<CSG_Project_Feedback__c> lstEngFeedback = [SELECT Id, PRJ180_Last_Reminder_Sent__c, PRJ180_Notification__c from CSG_Project_Feedback__c];
        System.assert(lstEngFeedback[0].PRJ180_Last_Reminder_Sent__c != null);
        System.assert(lstEngFeedback[0].PRJ180_Notification__c != null);
    }
    
    @isTest public static void testReminder3() {
        test.startTest();
        PRJ180_ReminderNotificationsBatch batch = new PRJ180_ReminderNotificationsBatch(3);
        ID batchprocessid = Database.executeBatch(batch);
        test.stopTest();
        List<CSG_Project_Feedback__c> lstEngFeedback = [SELECT Id, PRJ180_Last_Reminder_Sent__c, PRJ180_Notification__c from CSG_Project_Feedback__c];
        System.assert(lstEngFeedback[0].PRJ180_Last_Reminder_Sent__c != null);
        System.assert(lstEngFeedback[0].PRJ180_Notification__c != null);
    }
}