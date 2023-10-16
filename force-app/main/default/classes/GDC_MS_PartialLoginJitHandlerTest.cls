@isTest
public without sharing class GDC_MS_PartialLoginJitHandlerTest {

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
    static void testUserUpdateLogin(){
        //Get user id
        User u = [SELECT Id FROM User WHERE Email = 'testuser@salesforce.com' LIMIT 1];

        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = null;
        final Id portalId = null;
        final String FederationIdentifier = 'federationIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
                'User.FirstName'=>'test user',
                'User.FederationIdentifier'=>'testuser@salesforce.com',
                'User.Email'=>'testuser@salesforce.com',
                'User.LastName'=> 'GDCMS_user',
                'username' =>'testuser@salesforce.com',
                'is_portal_user' => 'false',
                'username' =>'testuser@testsample.com',
                'User.LocaleSidKey' =>'en_US',
                'User.EmailEncodingKey'=>'UTF-8',
                'User.TimeZoneSidKey'=>'America/New_York',
                'User.LanguageLocaleKey'=>'en_US',
                'User.Alias'=>'tlname'
                };
        final String assertion = 'assertion';

        Test.startTest();
        GDC_MS_PartialLoginJitHandler handler = new GDC_MS_PartialLoginJitHandler();
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        handler.updateUser(u.Id, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();

    }
}