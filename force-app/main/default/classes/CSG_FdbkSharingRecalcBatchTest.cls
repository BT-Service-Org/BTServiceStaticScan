@isTest
public class CSG_FdbkSharingRecalcBatchTest {
/**
    * we need to create the records in this order:
    * create users (use profile name CSG Base Profile)
    * create managers (Use profile name Standard User)
    * assign managers to users
    * update users
    * create contacts
    * create onboarding records by passing in contacts and users
    * create projects by passing in onboarding records
    * create feedback by passing in projects list
    * 
    * That should create the share records. Get those share records and store them somewhere. We will use them to compare later.
    * select a user or users, and change one or two managers in the manager hierarchy. Once done, get the updated share records.
    * 
    * Compare it to the one before manager chnages to make sure that the old managers don't have share and the new managers do.
    * 
    */
    
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
        
        //get the old share records for comparison later. Only get those created toda
        oldSharesList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM CSG_Project_Feedback__Share WHERE ParentId in :feedbackRecordIdList ORDER BY UserOrGroupId ASC];
        System.debug('oldSharesList size: ' + oldSharesList.size());
        for(CSG_Project_Feedback__Share sh : oldSharesList) {
            oldSharedUserOrGroupIdsList.add(sh.UserOrGroupId);
        }
        
        
        //now change the manager of one of the users.      
        System.runAs(thisUser) { //another mixed dml error without this. This time it will be share table vs. user modification
            
            List<User> newManagers = CSG_Engagement_Feedback_Test_DataFactory.createTestNewManagers(11, 'Standard User', true);
            //insert newManager;
            List<User> usersToChangeList = new List<User>();
            User userToChange1 = newUsers.get(0);
            User userToChange2 = newUsers.get(1);
            User userToChange3 = newUsers.get(2);
            User userToChange4 = newUsers.get(3);
            
            // The first if statement in CSG_UserTriggerHandler.reCalculateSharing will short-circuit at the first change, which will reduce test coverage
            // since the || is done over multiple lines. Also, the share table trigger only goes till level 9. So we will change managers from level 9 and above
            // to get full coverage of the if statement.
            userToChange1.Mgmt_Chain_Hierarchy_Level_09__c = newManagers[7].Id;
            userToChange2.Mgmt_Chain_Hierarchy_Level_10__c = newManagers[8].Id;
            userToChange3.Mgmt_Chain_Hierarchy_Level_11__c = newManagers[9].Id;
            userToChange4.Mgmt_Chain_Hierarchy_Level_12__c = newManagers[10].Id;
            
            usersToChangeList.add(userToChange1);
            usersToChangeList.add(userToChange2);
            usersToChangeList.add(userToChange3);
            usersToChangeList.add(userToChange4);
            
            update usersToChangeList;      
        }
        
        // get count of flagged users before the batch to use in assert after the Test.stopTest() call.
        flaggedUsersBeforeBatch = Database.countQuery('SELECT count() FROM User WHERE Mgmt_Hierarchy_Changed__c = true');
        //Integer flaggedUsersBeforeBatch;
        //Integer flaggedUsersAfterBatch;
        Id jobId = Database.executeBatch(new CSG_EngagementFeedbackSharingRecalcBatch(), 200);
        Test.stopTest();
        
        newSharesList = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM CSG_Project_Feedback__Share WHERE ParentId in :feedbackRecordIdList ORDER BY UserOrGroupId ASC];
        for(CSG_Project_Feedback__Share sh : newSharesList) {
            newSharedUserOrGroupIdsList.add(sh.UserOrGroupId);
        }
        
        // we are maintaining who the feedback record is shared with (UserOrGroupId) as two sets which will be ordered by UserOrGroupId. If the share table changed for the feebdack records
        // we created in this test run becuase of management hierarchy chnages, the two sets should not have the same elements. We can use the containsAll method of the Set class to check
        // whether the two sets are equal or not.
        Boolean result = oldSharedUserOrGroupIdsList.containsAll(newSharedUserOrGroupIdsList);
        System.debug(' ======  oldSharedUserOrGroupIdsList.containsAll(newSharedUserOrGroupIdsList)? ' +  result);
        // the old shares set and the new shares set should not be equal
        System.assertEquals(false, result, 'expecting false since the two share lists should not be equal');
        
        flaggedUsersAfterBatch = Database.countQuery('SELECT count() FROM User WHERE Mgmt_Hierarchy_Changed__c = true');
       
       // System.assertEquals(newUsers.size(), flaggedUsersBeforeBatch); // we are creating users in the test method and assigning managers so all those users should be flagged.
       // System.assertEquals(0, flaggedUsersAfterBatch); //the batch will reset all flags so there should be no users with the flag.
    }
}