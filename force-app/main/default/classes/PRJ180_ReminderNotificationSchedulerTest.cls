/**
 * Created by Rahul Mehta for PROJ-12 user story for Project 180 Feedback
 * For Testing of PRJ180_ReminderNotificationsScheduler.
*/ 
@isTest
public class PRJ180_ReminderNotificationSchedulerTest {
	@testsetup public static void testDataPrep() {
        List<User> lstNewUsers = new List<User>();
        List<User> lstManagers = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User adminUser = [SELECT Id, Name FROM user WHERE profile.name = 'System Administrator' AND isActive=true LIMIT 1];
        // Wihtout this we will get a MixedDML Operation Error becuase we are inserting a contact (inserting users calls USerToContactTrigger which calls UserConactUtil which inserts a contact) and users (setup object) in the same transaction.
        // To avoid that, we are doing a System.runAs call to sepearte out the contexts of execution between inserting a contact and users.
        System.runAs(thisUser) {
            lstNewUsers = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(1, 'CSG Base Profile', true);
            lstManagers = CSG_Engagement_Feedback_Test_DataFactory.createTestManagers(1, 'Standard User', true);
        }        
        List<Contact> contacts = CSG_Engagement_Feedback_Test_DataFactory.createTestContacts(1, true);        
        for(User usr : lstNewUsers) {
            usr.Mgmt_Chain_Hierarchy_Level_02__c = lstManagers[0].Id;
        }
        update lstNewUsers;
        List<PA_Onboarding__c> onboardingList = CSG_Engagement_Feedback_Test_DataFactory.createTestOnboardingRecords(contacts, lstNewUsers, true);        	
        List<PA_Onboarding_Project__c> projectsList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjects(onboardingList, true);            
        List<CSG_Project_Feedback__c> feedbackList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjectFeedback(projectsList, true);
        PRJ180_Feedback_Configuration__c csPRJ180Config = PRJ180_Feedback_Configuration__c.getOrgDefaults();
        csPRJ180Config.PRJ180_Reminder1__c = 4;
        csPRJ180Config.PRJ180_Reminder2__c = 7;
        csPRJ180Config.PRJ180_Reminder3__c = 11;
        insert csPRJ180Config;
    }
    
    @isTest public static void testScheudlingOfBatch() {
        String cronExp = returnCronExpr();
        Test.startTest();
        String jobId = System.schedule('Test PRJ180 Reminder Batch Schedule', cronExp, new PRJ180_ReminderNotificationsScheduler(1));
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        // nextDay returns YYYY-MM-DD, no time, so adding midnight to the string value of date to check next fire time  
        System.assertEquals(String.valueOf(system.today().addDays(1)) + ' 00:00:00', String.valueOf(ct.NextFireTime));
    }
	
    private static string returnCronExpr() {
        Date nextDay = System.today().addDays(1);
        Integer year = nextDay.year();
        Integer month = nextDay.month();
        Integer day = nextDay.day();   
        String cronExp = '0 0 0 ' + day + ' ' +  month + ' ? ' + year; // schedule for midnight next day.
        return cronExp;
    }
}