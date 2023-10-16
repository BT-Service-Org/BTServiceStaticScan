@isTest(SeeAllData=true)
private class CSG_UserTriggerHandlerTest {
           
    @isTest public static void testMgmtHierarchyChangeFlag() {
        
        List<User> newUsers = CSG_Engagement_Feedback_Test_DataFactory.createTestUsers(25, 'CSG Base Profile', true);
        List<User> managers = CSG_Engagement_Feedback_Test_DataFactory.createTestManagers(11, 'Standard User', true);
        List<User> checkFlagsList = new List<User>(); 
        
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
        
        Test.startTest();
        update newUsers;
        List<User> newManagers = CSG_Engagement_Feedback_Test_DataFactory.createTestNewManagers(11, 'Standard User', true);
        //insert newManager;
        List<User> usersToChangeList = new List<User>();
        User userToChange1 = newUsers.get(0);
        User userToChange2 = newUsers.get(1);
        User userToChange3 = newUsers.get(2);
        User userToChange4 = newUsers.get(3);
        
        // The first if statement in CSG_UserTriggerHandler.setUserHierarchyChangeFlag will short-circuit at the first change, which will reduce test coverage
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
        
        update usersToChangeList; //these are the same users who have already been flagged so the list size in the query below won't change.
        checkFlagsList = [Select id, Mgmt_Hierarchy_Changed__c from User where Mgmt_Hierarchy_Changed__c = true];
        Test.stopTest();
        
        System.assertEquals(checkFlagsList.size(), newUsers.size());
        
    }
}