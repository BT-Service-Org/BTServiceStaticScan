@isTest
public with sharing class CSG_Engagement_Feedback_Test_DataFactory {
    
    /*
        create users for testing. The method takes 3 parameters:
        count: count of how many users to create
        profileName: which profile these users should have
        doInsert: whether this method will do the insert operation or not. This gives freedom to the calling class to dictate whether users should be inserted or if it will take care of insert.
    */
    public static List<User> createTestUsers(Integer count, String profileName, Boolean doInsert) {
        List<User> newUsersList = new List<User>();
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName Limit 1].Id;

        UserRole userRole = new UserRole(DeveloperName = 'TestingTeam', Name = 'Testing Team');
        insert userRole;

        for(Integer i = 0; i < count; i++) {
            User u = new User(
                    ProfileId = profileId,
                    LastName = 'last' + i,
                    FirstName = 'first' + i,
                    Email =  'last' + i + '.' + 'first' + i + '@awesomesauce.com',
                    Username = 'last' + i + '.' + 'first' + i + '@awesomesauce.com',
                    CompanyName = 'Testing Co',
                    Title = 'Captian',
                    Alias = 'alias' + i,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    UserRoleId = userRole.Id,
                    IsActive = true
                );

                newUsersList.add(u);
        }

        if(doInsert) {
            //prevent UserContactTrigger from running. We only need the base data. This trigger also creates contacts, etc. which we don't need.
            UserContactUtil.doNotExecuteTrigger = true;
            insert newUsersList;
        }

        return newUsersList;
    }

    /*
        create users for testing. The method takes 3 parameters:
        count: count of how many users to create
        profileName: which profile these users should have
        doInsert: whether this method will do the insert operation or not. This gives freedom to the calling class to dictate whether users should be inserted or if it will take care of insert.
    */
    public static List<User> createTestManagers(Integer count, String profileName, Boolean doInsert) {
        List<User> managersList = new List<User>();
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName Limit 1].Id;

        UserRole userRole = new UserRole(DeveloperName = 'TestingTeamManager', Name = 'Testing Team Manager');
        insert userRole;

        for(Integer i = 0; i < count; i++) {                      
            User u = new User(
                    ProfileId = profileId,
                    LastName = 'Manager' + i,
                    FirstName = 'Boss' + i,
                    Email =  'Manager' + i + '.' + 'Boss' + i + '@awesomesauce.com',
                    Username = 'Manager' + i + '.' + 'Boss' + i + '@awesomesauce.com',
                    CompanyName = 'Testing Co',
                    Title = 'The Boss',
                    Alias = 'Malias' + i,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    UserRoleId = userRole.Id,
                    IsActive = true
                );

                managersList.add(u);
        }
        
        // !!!! WARNING !!!! This code will need adjustment later. The "active user" check done in the lookup filter for Engagement Feedback's Assignment__c field relies
        // on the fact that the level 2 management hierarchy manager has the last name 'Millham'. This should go away since we can't gurantee it will always be Millham.
        // the active status should be looking at the User.IsActive field only.
        
        managersList.get(0).LastName = 'Millham';

        if(doInsert) {
            //prevent UserContactTrigger from running. We only need the base data. This trigger also creates contacts, etc. which we don't need.
            UserContactUtil.doNotExecuteTrigger = true;
            insert managersList;
        }

        return managersList;
    }
    
    public static List<User> createTestNewManagers(Integer count, String profileName, Boolean doInsert) {
        List<User> managersList = new List<User>();
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName Limit 1].Id;

        UserRole userRole = new UserRole(DeveloperName = 'NewTestingTeamManager', Name = 'New Testing Team Manager');
        insert userRole;

        for(Integer i = 0; i < count; i++) {                      
            User u = new User(
                    ProfileId = profileId,
                    LastName = 'New Manager' + i,
                    FirstName = 'New Boss' + i,
                    Email =  'NewManager' + i + '.' + 'NewBoss' + i + '@awesomesauce.com',
                    Username = 'NewManager' + i + '.' + 'NewBoss' + i + '@awesomesauce.com',
                    CompanyName = 'Testing Co',
                    Title = 'The Boss',
                    Alias = 'Nalias' + i,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    UserRoleId = userRole.Id,
                    IsActive = true
                );

                managersList.add(u);
        }
        
        // !!!! WARNING !!!! This code will need adjustment later. The "active user" check done in the lookup filter for Engagement Feedback's Assignment__c field relies
        // on the fact that the level 2 management hierarchy manager has the last name 'Millham'. This should go away since we can't gurantee it will always be Millham.
        // the active status should be looking at the User.IsActive field only.
        
        managersList.get(0).LastName = 'Millham';

        if(doInsert) {
            //prevent UserContactTrigger from running. We only need the base data. This trigger also creates contacts, etc. which we don't need.
            UserContactUtil.doNotExecuteTrigger = true;
            insert managersList;
        }

        return managersList;
    }

    public static List<Contact> createTestContacts(Integer count, Boolean doInsert){
        List<Contact> contactsList = new List<Contact>();

        for(Integer i = 0; i < count; i++) {
            contactsList.add(new Contact(FirstName = 'first' + i, LastName = 'last' + i, Email = 'first' + i + 'last' + i + '@testContact.com'));
        }

        if(doInsert) {
            insert contactsList;
        }

        return contactsList;
    }

    /**
     * Create test onboarding records. The method takes the following input:     
     * contacts: list of contacts to assign to the onboarding records using teh Contact__c field
     * users: list of users to assign to the onboarding records using the Candidate__c field. We will use users.size() to create onboarding records list.
     *          While assigning contacts we check if the current loop loop index is less than contacts.size() and then access the contacts list items.
     * doInsert: whether this method will do the insert operation or not. This gives freedom to the calling class to dictate whether records should be inserted or if it will care of the insert.
     */
    public static List<PA_Onboarding__c> createTestOnboardingRecords(List<Contact> contacts, List<User> users, Boolean doInsert) {
        List<PA_Onboarding__c> onboardingList = new List<PA_Onboarding__c>();
        Id paRecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;

        for(Integer i = 0; i < users.size(); i++) {
            if(i >= contacts.size()) {
                break; // there are more users than contacts, exit the loop to avoid list index out of bounds error.
            }

            PA_Onboarding__c onb = new PA_Onboarding__c();
            onb.RecordTypeId = paRecordTypeId;
            onb.Name = 'Onboarding ' + i;
            onb.Program_Start_Date__c = System.today();
            onb.Contact__c = contacts.get(i).Id;
            onb.Candidate_Email__c = contacts.get(i).email;
            onb.Candidate__c = users.get(i).Id;

            onboardingList.add(onb);
        }

        if(doInsert) {
            //Disable trigger, to only create Onboarding test data. Without this we will run into Apex CPU Limit breach
            LPOnboardingPrepareTriggerHandler.disable = true;
            insert onboardingList;
        }

        return onboardingList;
    }

    /**
     * create pa onboarding project records. The method takes the following inpu:t
     * onboardingList: list of onboarding records. We use these to create the project records.
     * doInsert: whether this method will do the insert operation or not. This gives freedom to the calling class to dictate whether records should be inserted or if it will care of the insert.
     */
    public static List<PA_Onboarding_Project__c> createTestProjects(List<PA_Onboarding__c> onboardingList, Boolean doInsert) {

        List<PA_Onboarding_Project__c> projectsList = new List<PA_Onboarding_Project__c>();

        for(PA_Onboarding__c onb : onboardingList) {
            PA_Onboarding_Project__c prj = new PA_Onboarding_Project__c();

            prj.PA_Onboarding__c = onb.Id;
            prj.Consultant__c = onb.Contact__c;
            prj.Project_Start_Date__c = System.today();
            prj.Project_End_Date__c = System.today().addDays(365);
            prj.Project_Name__c = 'Test ProjData for ' + onb.Name;
            prj.Type__c = 'Billable';

            projectsList.add(prj);

        }

        if(doInsert) {
            insert projectsList;
        }

        return projectsList;
    }

    /**
     * create a list of project feedback records. This method takes the following input:
     * projectsList: list of projects which will be used to create the feedback records
     * doInsert: whether this method will do the insert operation or not. This gives freedom to the calling class to dictate whether records should be inserted or if it will care of the insert.
     */
    public static List<CSG_Project_Feedback__c> createTestProjectFeedback(List<PA_Onboarding_Project__c> projectsList, Boolean doInsert) {
        List<CSG_Project_Feedback__c> feedbackList = new List<CSG_Project_Feedback__c>();

        for(PA_Onboarding_Project__c prj : projectsList) {
            CSG_Project_Feedback__c prjFdbck = new CSG_Project_Feedback__c();

            prjFdbck.Assignment__c = prj.Id; 
            prjFdbck.Onboarding__c = prj.PA_Onboarding__c;//try contact next
            prjFdbck.Comments__c = 'New Comment for ' + prj.Project_Name__c;
            prjFdbck.CSG_Feedback_Provider__c = UserInfo.getUserId();
            prjFdbck.Unique_Feedback_Id__c = prjFdbck.Assignment__c + '-' + prjFdbck.Onboarding__c + '-' + UserInfo.getUserId() ;

            feedbackList.add(prjFdbck);
            
        }

        if(doInsert) {
            insert feedbackList;
        }

        return feedbackList;
    }
}