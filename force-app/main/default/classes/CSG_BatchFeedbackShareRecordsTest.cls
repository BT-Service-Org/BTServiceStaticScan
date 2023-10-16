/**
* @author         Shiva Pasumarty
* @created        08/08/2023
* @description    Test class for CSG_BatchtoCreateFeedbackShareRecords.

* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* @date           @modified           @description                    
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest(seeAllData = false)
public class CSG_BatchFeedbackShareRecordsTest {
    @isTest public static void testSharingRecalc() {
        List<User> newUsers = new List<User>();
        List<User> managers = new List<User>();
        List<CSG_Project_Feedback__Share> oldSharesList = new List<CSG_Project_Feedback__Share>();
        List<CSG_Project_Feedback__Share> newSharesList = new List<CSG_Project_Feedback__Share>();
        Set<String> feedbackRecordIdList = new Set<String>();
        Set<String> oldSharedUserOrGroupIdsList = new Set<String>();
        Set<String> newSharedUserOrGroupIdsList = new Set<String>();
        
        Integer flaggedUsersBeforeBatch;
        Integer flaggedUsersAfterBatch;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User adminUser = [SELECT Id, Name FROM user WHERE profile.name = 'System Administrator' AND isActive=true LIMIT 1];
        
        Test.startTest();
        // Wihtout this we will get a MixedDML Operation Error becuase we are inserting a contact (inserting users calls USerToContactTrigger which calls UserConactUtil which inserts a contact) and users (setup object) in the same transaction.
        // To avoid that, we are doing a System.runAs call to sepearte out the contexts of execution between inserting a contact and users.
        System.runAs(thisUser) {
            newUsers = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(25, 'CSG Base Profile', true);
            managers = CSG_Engagement_Feedback_Test_DataFactory.createTestManagers(11, 'Standard User', true);
        }
        
        
        System.debug('newUsers before mangers' + newUsers);
        for(User usr : newUsers) {
            usr.Mgmt_Chain_Hierarchy_Level_02__c = managers[0].Id;
            usr.Mgmt_Chain_Hierarchy_Level_03__c = managers[1].Id;
            usr.Mgmt_Chain_Hierarchy_Level_04__c = managers[2].Id;
            usr.Mgmt_Chain_Hierarchy_Level_05__c = managers[3].Id;
            usr.Mgmt_Chain_Hierarchy_Level_06__c = managers[4].Id;
            usr.Mgmt_Chain_Hierarchy_Level_07__c = managers[5].Id;
            usr.Mgmt_Chain_Hierarchy_Level_08__c = managers[6].Id;
            usr.Mgmt_Chain_Hierarchy_Level_09__c = managers[7].Id;
            usr.Mgmt_Chain_Hierarchy_Level_10__c = managers[8].Id;
            usr.Mgmt_Chain_Hierarchy_Level_11__c = managers[9].Id;
            usr.Mgmt_Chain_Hierarchy_Level_12__c = managers[10].Id;
        }
        
        update newUsers;
        
        System.debug('newUsers after mangers' + newUsers);
        System.debug(' ===== newUsers[0].Mgmt_Chain_Hierarchy_Level_12__c: ' + newUSers.get(0).Mgmt_Chain_Hierarchy_Level_12__c);
        
        
        List<Contact> contacts = CSG_Engagement_Feedback_Test_DataFactory.createTestContacts(15, true);        
        List<PA_Onboarding__c> onboardingList = CSG_Engagement_Feedback_Test_DataFactory.createTestOnboardingRecords(contacts, newUsers, true);        	
        List<PA_Onboarding_Project__c> projectsList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjects(onboardingList, true);            
        List<CSG_Project_Feedback__c> feedbackList = CSG_Engagement_Feedback_Test_DataFactory.createTestProjectFeedback(projectsList, true);
        
        for(CSG_Project_Feedback__c fdbk : feedbackList) {
            feedbackRecordIdList.add(fdbk.Id);
        }
        
        //get the old share records for comparison later. Only get those created today
        oldSharesList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM CSG_Project_Feedback__Share WHERE ParentId in :feedbackRecordIdList and RowCause='Management_Hierarchy__c' ORDER BY UserOrGroupId ASC];
        System.debug('oldSharesList size Before: ' + oldSharesList.size());
        delete oldSharesList;
        newSharesList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM CSG_Project_Feedback__Share WHERE ParentId in :feedbackRecordIdList and RowCause='Management_Hierarchy__c' ORDER BY UserOrGroupId ASC];
        System.assert(newSharesList.size()==0, 'Size should be zero');
        Id jobId = Database.executeBatch(new CSG_BatchtoCreateFeedbackShareRecords(), 200);
        
        Test.stopTest();
        newSharesList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM CSG_Project_Feedback__Share WHERE ParentId in :feedbackRecordIdList and RowCause='Management_Hierarchy__c' ORDER BY UserOrGroupId ASC];
        System.debug('newSharesList size After: ' + newSharesList.size());
        System.assert(newSharesList.size()>0, 'Size should be greater than zero');
        
    }
}