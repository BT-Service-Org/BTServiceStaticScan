@isTest
public without sharing class GDCMSUserSearchTest {

    @TestSetup
    static void createUserData(){

        Account a = new Account();
        a.Name = 'Salesforce.com - DO NOT TOUCH';
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User();
        u.FirstName = 'test user';
        u.LastName = 'GDCMS_user';
        u.Email = 'testuser@salesforce.com';
        u.FederationIdentifier = 'testuser@salesforce.com';
        u.Username = 'testuser12312312212@sampletest.com';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'America/New_York';
        u.ProfileId = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.Alias = 'test';

        insert u;

    }

    @IsTest
    public static void userSearchTest(){
        Test.startTest();
        List<User> userList = GDCMSUserSearch.searchUser('test');
        List<Id> userIds = new List<Id>();
        for (User u : userList) {
            userIds.add(u.Id);
        }
        GDCMSUserSearch.assignPermissionSet(userIds);
        Test.stopTest();
    }

}