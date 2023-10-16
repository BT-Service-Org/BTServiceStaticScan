/**
* @author         Vaishnavi Sreedhar <vaishnavi.sreedhar@salesforce.com>
* @created        09-05-2023
* @description    Schedule and batch implementation for PROJ-10: Sending Engagement Feedback Request on a schedule.
                  Test class for PRJ180_InitiateFeedbackRequestBatch.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* @date           @modified           @description                    
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest(seeAllData = false)
public class PRJ180_InitiateFeedbackRequestBatchTest {
    @testsetup public static void setup() {
       	List<User> userList = new List<User>();
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            userList = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(2, 'CSG Base Profile', true);
            userList[0].country = 'Denmark';
            update userList;
        }        
        
        List<Contact> contactList = CSG_Engagement_Feedback_Test_DataFactory.createTestContacts(2, true);        
        List<PA_Onboarding__c> onboardingList = CSG_Engagement_Feedback_Test_DataFactory.createTestOnboardingRecords(contactList, userList, true);        	
        List<PA_Onboarding_Project__c> projectList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjects(onboardingList, false); 
        projectList[0].Project_End_Date__c = System.today();
        projectList[0].Billable_Hours__c = 25;
        projectList[1].Project_Start_Date__c = System.today().addMonths(-8);
        projectList[1].Project_End_Date__c = System.today().addMonths(2);
        projectList[1].PRJ180_Feedback_Completion_Date__c = System.today().addMonths(-7);
        projectList[1].Project_Role__c = 'test - 0 rate test';

        insert projectList;
        insert new PRJ180_Feedback_Configuration__c(PRJ180_Enable_6_Month_Feedback_Request__c = true);
    } 
    
  	@isTest public static void testInitiateFeedback() {
        Test.startTest();
        PRJ180_InitiateFeedbackRequestBatch batch = new PRJ180_InitiateFeedbackRequestBatch();
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();
        
        List<PA_Onboarding_Project__c> testProjectList = [SELECT Id, PRJ180_Initiate_Feedback__c FROM PA_Onboarding_Project__c LIMIT 2];
        System.assert(testProjectList[0].PRJ180_Initiate_Feedback__c, 'Initiate Feedback unchecked for end date criteria');
        System.assert(testProjectList[1].PRJ180_Initiate_Feedback__c, 'Initiate Feedback unchecked for six month criteria');
    }
    
   	@isTest public static void testScheduler() {
        Test.startTest();
        PRJ180_InitiateFeedbackRequestBatch scheduler = new PRJ180_InitiateFeedbackRequestBatch();
        String sch = '0 0 0 ? * MON'; 
        String schedulerId = System.schedule('Scheduler Test', sch, scheduler); 
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :schedulerId];
        System.assertEquals(sch, ct.CronExpression, 'Apex class not scheduled for run'); 
    }
}