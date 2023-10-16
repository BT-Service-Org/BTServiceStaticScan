@isTest
private class OrgRefresh_AuthUtilsTest {
    
    @isTest static void testRedirectAuthScreen() {
        // Implement test code
        //call the utility method to insert the org profile
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        //invoke the function to redirect the user to auth screen
        PageReference pageRef=OrgRefresh_AuthUtils.redirectAuthScreen();

        //construct the expected URL
        String responseTypeStr='?response_type=code&client_id=aaaaa';
        String redirect_uri='&redirect_uri=' + EncodingUtil.urlEncode('https://test.callback.com', 'UTF-8');

        String expectedURL='https://test.com/services/oauth2/authorize' + responseTypeStr + redirect_uri + '&display=page&immediate=false';

        PageReference expectedPageRef=new PageReference(expectedURL);
        expectedPageRef.setRedirect(true);
        
        //validate pageRef value
        System.assertEquals(expectedPageRef.getUrl(),pageRef.getUrl());
    }
    @future(callout=true)
    static void authenticateUserAuthFlow(){
         String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_WEBFLOW, 'testauthcode', true);
    }

    @future(callout=true)
    static void authenticateUserAuthFlowInvalid(){
         try{
            String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN, 'testauthcode', true);
         }
         catch(Exception e){
            System.assertEquals(e.getMessage(),'Invalid oauth flow specified');
         }
         
    }

    @future(callout=true)
    static void authenticateUserRefreshTokenFlow(){
         String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN, true);
    }

    @future(callout=true)
    static void authenticateUserRefreshTokenFlowInvalid(){
         try{
            String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN, true);
         }
         catch(Exception e){
            System.assertEquals(e.getMessage(),'No Refresh Token or Invalid Refresh Token');
         }
         
    }

    @future(callout=true)
    static void authenticateUserNamePasswordFlow(){
         String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD, 'Test Class Created Org', 'testclass@username.com', true);
    }

    @future(callout=true)
    static void invalidOrgOrUserNameFlow(){
         try{
           String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.USERNAME_PASSWORD, 'Test Class Created Org', 'testclass@username.com', true);
         }
         catch(Exception e){
            System.assertEquals(e.getMessage(),'No credentials defined for username and orgname');
         }

    }

    @future(callout=true)
    static void invalidAuthFlowSpecified(){
         try{
            //calling the username password polymorphic method by passing the refresh token flow
           String accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN, 'Test Class Created Org', 'testclass@username.com', true);
         }
         catch(Exception e){
            System.assertEquals(e.getMessage(),'Invalid oauth flow specified');
         }

    }

    @isTest static void testauthenticateUserNamePasswordFlow(){
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/14/2014
        
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockUserNamePasswordTest());

        
        //call the utility method to insert the org profile
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
        insert refreshProfile;

        //insert into the org refresh cred object to store the password and user name for the specified org. Password is stored as encrypted field.
        Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
        //set the name field to be org name
        refreshCreds.Name='Test Class Created Org';
        refreshCreds.User_Name__c='testclass@username.com';
        refreshCreds.Password__c='dummypassword';
        insert refreshCreds;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        authenticateUserNamePasswordFlow();
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //validate the access token
        System.assertEquals('test_access_token_username+password_flow',refreshProfile.Access_Token__c);
        //no refresh token is returned in username password flow
        System.assertEquals(null,refreshProfile.Refresh_Token__c);
        System.assertEquals('https://test.unamepwd.auth.com',refreshProfile.Instance_URL__c);
        
    }
    
    //Invalid flow for the username password sequence.
    @isTest static void testInvalidUserNamePwdFlow(){
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockUserNamePasswordTest());

        
        //call the utility method to insert the org profile
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
        insert refreshProfile;

        //insert into the org refresh cred object to store the password and user name. Password is stored as encrypted field.
        //Deliberately an invalid org name is specified to test the scenario, when an org name is not found.
        Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
        //set the name field to be org name
        refreshCreds.Name='Test Invalid Org';
        refreshCreds.User_Name__c='testclass@username.com';
        refreshCreds.Password__c='dummypassword';
        insert refreshCreds;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        invalidOrgOrUserNameFlow();
        invalidAuthFlowSpecified();
        
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //Callouts would not succeed due to the exception.
        System.assertEquals(null,refreshProfile.Access_Token__c);
        //no refresh token is returned in username password flow
        System.assertEquals(null,refreshProfile.Refresh_Token__c);
        System.assertEquals(null,refreshProfile.Instance_URL__c);
        
    }

    

    @isTest static void testauthenticateUserRefreshTokenFlow(){
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockRefreshTokenTest());

        
        //call the utility method to insert the org profile
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
        insert refreshProfile;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        authenticateUserRefreshTokenFlow();
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //validate the access token
        System.assertEquals('test_access_token_refresh_token_flow',refreshProfile.Access_Token__c);
        //refresh token isn't changed by the callout.
        System.assertEquals('test_refresh_token',refreshProfile.Refresh_Token__c);
        System.assertEquals('https://test.refreshtoken.auth.com',refreshProfile.Instance_URL__c);
        
    }
    //invalid test case of the above test method testauthenticateUserRefreshTokenFlow
    @isTest static void testauthenticateUserRefreshTokenFlowInvalid(){
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014
        
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockRefreshTokenTest());

        
        //call the utility method to insert the org profile. Pass an invalid auth flow so that refresh token is not created.
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        authenticateUserRefreshTokenFlowInvalid();
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //Callouts should not succeed due to refresh token not being specified.
        System.assertEquals(null,refreshProfile.Access_Token__c);
        //refresh token isn't changed by the callout.
        System.assertEquals(null,refreshProfile.Refresh_Token__c);
        System.assertEquals(null,refreshProfile.Instance_URL__c);
        
    }
    
    @isTest static void testauthenticateUserAuthCode() {
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockAuthFlowTest());

        
        //call the utility method to insert the org profile
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');   // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        authenticateUserAuthFlow();
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //validate the access token
        System.assertEquals('test_access_token',refreshProfile.Access_Token__c);
        System.assertEquals('test_refresh_token',refreshProfile.Refresh_Token__c);
        System.assertEquals('https://test.auth.com',refreshProfile.Instance_URL__c);
    }

    //Invalid case of the above unit test method testauthenticateUserAuthCode
    @isTest static void testauthenticateOauthFlowNegative(){
        // Implement test code
        // Set mock callout class 
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014
       
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockAuthFlowTest());

        
        //call the utility method to insert the org profile. Create with refresh token flow. However, we are calling the web auth method 
        //that doesn't have the refresh token populated. So should return invalid oauth
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;
        
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org');  // Updated by SD - 06/24/2014

        //invoke the method to authenticate as a future method so that all the params can be updated in custom settings and validated.
        Test.startTest();
        authenticateUserAuthFlowInvalid();
        Test.stopTest();

        //refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();  // Updated by SD - 06/24/2014

        //callouts should not have succeeded due to exception
        System.assertEquals(null,refreshProfile.Access_Token__c);
        System.assertEquals(null,refreshProfile.Refresh_Token__c);
        System.assertEquals(null,refreshProfile.Instance_URL__c);
    }
    
}