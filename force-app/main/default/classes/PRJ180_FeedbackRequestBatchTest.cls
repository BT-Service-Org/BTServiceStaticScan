/**
* @author         Vaishnavi Sreedhar <vaishnavi.sreedhar@salesforce.com>
* @created        10-05-2023
* @description    Schedule and batch implementation for PROJ-10: Sending Engagement Feedback Request on a schedule.
                  Test class for PRJ180_FeedbackRequestBatch.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* @date           @modified           @description                    
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest(seeAllData = false)
public class PRJ180_FeedbackRequestBatchTest {
    @testsetup public static void setup() {
       	List<User> userList = new List<User>();
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            userList = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(3, 'CSG Base Profile', true);
        }        
        
        List<Contact> contactList = CSG_Engagement_Feedback_Test_DataFactory.createTestContacts(4, true);    
        contactList[0].User_Record__c = userList[0].Id;
        contactList[1].User_Record__c = userList[1].Id;
        contactList[2].User_Record__c = userList[2].Id;
        update contactList;
        
        List<PA_Onboarding__c> onboardingList = CSG_Engagement_Feedback_Test_DataFactory.createTestOnboardingRecords(contactList, userList, true);        	
        List<PA_Onboarding_Project__c> projectList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjects(onboardingList, false); 
        for(PA_Onboarding_Project__c project: projectList){
        	project.Project_ID__c = 'a0x1234567';  
            project.PRJ180_Initiate_Feedback__c = true;  
        } 
        projectList[0].Project_Role__c = 'Engagement Manager';
        projectList[1].Project_Role__c = 'Senior Developer';
        //projectList[2].Project_Role__c = 'Developer';
        insert projectList;
    } 
    
  	@isTest public static void testCreateFeedbackRequest() {
        Test.startTest();
        PRJ180_FeedbackRequestBatch batch = new PRJ180_FeedbackRequestBatch();
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();

        Integer feedbackCount = [SELECT Count() FROM CSG_Project_Feedback__c];
        System.debug('feedbackCount --->>' + feedbackCount);
        System.assert(feedbackCount == 2, 'Count of Feedback Request created is incorrect');
    }
    
   	@isTest public static void testBlankFeedbackProvider() {
        insert new PRJ180_Feedback_Configuration__c(PRJ180_Disable_Blank_Feedback_Provider__c = true);
        
        Test.startTest();
        PRJ180_FeedbackRequestBatch batch = new PRJ180_FeedbackRequestBatch();
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();

        Integer feedbackCount = [SELECT Count() FROM CSG_Project_Feedback__c];
        System.debug('feedbackCount --->>' + feedbackCount);
        System.assert(feedbackCount == 2, 'Count of Feedback Request created is incorrect');
    }   
    
}