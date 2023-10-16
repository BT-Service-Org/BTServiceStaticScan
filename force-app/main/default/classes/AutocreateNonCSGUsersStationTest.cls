@isTest(SeeAllData=true)
public class AutocreateNonCSGUsersStationTest {
    
    
    private static testMethod void createUser_test() {
        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = null;
        final Id portalId = null;
        final String federationIdentifier = 'federationIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
            'email'=> 'grayson.mack@salesforce.com',
                'is_portal_user' => 'false',
                'userId' => '0050W000006ljhE',
                'username' =>'rayson.mack@sso.salesforce.com'
                };
        final String assertion = 'assertion';
                
        Test.startTest();
        AutocreateNonCSGUsersStation  handler = new AutocreateNonCSGUsersStation ();
        AutocreateNonCSGUsersStation.org62UserMockList.add(setupMockTestData());
        handler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();
        
        // Select more fields and do more assertions than this
        //   User newUser = [SELECT Email, IsActive, CommunityNickname, FederationIdentifier FROM User];
        
    }
    
    
    private static testMethod void updateUser_test() {
        final Id samlSsoProviderId = '0LE000000000000';
        final Id communityId = null;
        final Id portalId = null;
        final Id userId = '0050W000006ljhE';
        final String federationIdentifier = 'federationIdentifier';
        final Map<String, String> attributes = new Map<String, String> {
            'email'=> 'grayson.mack@salesforce.com',
                'is_portal_user' => 'false',
                'userId' => '0050W000006ljhE',
                'username' =>'rayson.mack@sso.salesforce.com'
                };
        final String assertion = 'assertion';
        
        Test.startTest();
        AutocreateNonCSGUsersStation  handler = new AutocreateNonCSGUsersStation ();
        AutocreateNonCSGUsersStation.org62UserMockList.add(setupMockTestData());
        handler.updateUser(userId,samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        Test.stopTest();
        
        // Select more fields and do more assertions than this
        //   User newUser = [SELECT Email, IsActive, CommunityNickname, FederationIdentifier FROM User];
    }
    
    private static Org62_User__x setupMockTestData(){
        // create Mock Data here 
        Org62_User__x mockeduser = new Org62_User__x(
            Email__c='grayson.mack@salesforce.com',
            ExternalId='0052D000001xwmZQAQ',
            FirstName__c='Grayson',
            LastName__c='Mack',
            Username__c='grayson.mack@salesforce.com.preproduat',
            Alias__c = 'gmack',
            TimeZoneSidKey__c='America/Los_Angeles',
            LocaleSidKey__c='en_US',
            EmailEncodingKey__c ='ISO-8859-1',
            LanguageLocaleKey__c='en_US'
        );
        
        return mockeduser;
    }      
    
}