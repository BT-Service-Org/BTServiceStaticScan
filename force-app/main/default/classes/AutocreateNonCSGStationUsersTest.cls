@isTest
private class AutocreateNonCSGStationUsersTest {
    private static testMethod void createUser_test() {
        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = null;
        final Id portalId = null;
        final String FederationIdentifier = 'federationIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
                'User.Department'=> 'Test Department',
                'User.FirstName'=>'FNameTest',
                'User.Title'=>'Test Title',
                'User.FederationIdentifier'=>'TestFedIdentifier',
                'User.Email'=>'testemail26012020@salesforce.com',
                'User.LastName'=> 'LNameTest',
                'is_portal_user' => 'false',
                'username' =>'testuser@testsample.com'
                };
        final String assertion = 'assertion';
                
        Test.startTest();
        AutocreateNonCSGStationUsers  handler = new AutocreateNonCSGStationUsers ();
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();
        
        
    }
    
    
    private static testMethod void updateUser_test() {
        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = null;
        final Id portalId = null;
        final Id userId = '0053A00000FGA9mQAH';
        final String federationIdentifier = 'TestFedIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
                'User.Department'=> 'Test Department',
                'User.FirstName'=>'FNameTest',
                'User.Title'=>'Test Title',
                'User.FederationIdentifier'=>'TestFedIdentifier',
                'User.Email'=>'testemail26012020@salesforce.com',
                'User.LastName'=> 'LNameTest',
                'is_portal_user' => 'false',
                'username' =>'testuser@testsample.com',
                'User.LocaleSidKey' =>'en_US',
                'User.EmailEncodingKey'=>'UTF-8',
                'User.TimeZoneSidKey'=>'America/New_York',
                'User.LanguageLocaleKey'=>'en_US',
                'User.Alias'=>'tlname'
                
               };
        final String assertion = 'assertion';
        
        Account acc = new Account();
        acc.Name= 'Salesforce.com - DO NOT TOUCH';
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='CSG Base Profile'];
          Blob b = Crypto.GenerateAESKey(128);
          String h = EncodingUtil.ConvertTohex(b);
          String uid = h.SubString(0,8);
          User u = new User(Alias = uid, Email= 'testemail26012020@salesforce.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',federationIdentifier='TestFedIdentifier'); 
          
          insert u;
          
        Test.startTest();
        AutocreateNonCSGStationUsers  handler = new AutocreateNonCSGStationUsers ();
        handler.updateUser(null,samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();
        
        }
}