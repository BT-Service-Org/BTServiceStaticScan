@isTest
public with sharing class UserDataAccessorTest {
    private static User buildUser(String email) {
        UserContactUtil.doNotExecuteTrigger = true;
        return new User(
            Email = email,
            FederationIdentifier = email,
            Slack_User_Id__c = 'slack user id',
            Username = 'testkjlsfakjgio' + email,
            LastName = 'test',
            Alias = 'test',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_us',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                WITH SECURITY_ENFORCED
            ]
            .Id,
            LanguageLocaleKey = 'en_us'
        );
    }

    @isTest
    public static void getSlackUserInfoFromUserIds_givenUserInDb_shouldReturnSlackInfoFields() {
        User u = buildUser('test@example.com');
        insert u;

        Test.startTest();
        List<User> returnedUsers = new UserDataAccessor()
            .getSlackUserInfoFromUserIds(new Set<Id>{ u.Id });
        Test.stopTest();

        System.assertEquals(1, returnedUsers.size(), 'should return 1 user');
        System.assertEquals(
            u.FederationIdentifier,
            returnedUsers[0].FederationIdentifier,
            'should return fed id'
        );
        System.assertEquals(
            u.Slack_User_Id__c,
            returnedUsers[0].Slack_User_Id__c,
            'should return Slack User Id'
        );
    }

    @isTest
    public static void updateUsers_givenUsers_shouldUpdateInDB() {
        User u = buildUser('test@example.com');
        insert u;

        u.Email = 'test2@example.com';

        Test.startTest();
        List<User> returnedUsers = new UserDataAccessor()
            .updateUsers(new List<User>{ u });
        Test.stopTest();

        System.assertEquals(1, returnedUsers.size(), 'should return 1 user');
        System.assertEquals(
            u.Email,
            returnedUsers[0].Email,
            'should return updated user'
        );
        System.assertEquals(
            u.Email,
            [SELECT Email FROM User WHERE Id = :u.Id WITH SECURITY_ENFORCED]
            .Email,
            'should update user in db'
        );
    }
}