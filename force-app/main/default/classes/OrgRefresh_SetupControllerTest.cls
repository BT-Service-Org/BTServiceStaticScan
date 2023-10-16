@isTest
private class OrgRefresh_SetupControllerTest {
    
    @isTest static void testCreateNewOrgProfile() {
        // Implement test code
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        setUpCtrl.newOrgName='Test class created new org';

        setUpCtrl.createNewOrgProfile();
        System.assertEquals(setUpCtrl.refreshProfInstance.Name,'Test class created new org');
        System.assertEquals(setUpCtrl.orgSelections.size(),1);
    }
    
    @isTest static void testgetDefinedUserNames() {
        // Implement test code
       //insert into the org refresh cred object to store the password and user name for the specified org. Password is stored as encrypted field.
       Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='Test Class Created Org 1';
       refreshCreds.User_Name__c='testclass@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;

       refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='Test Class Created Org 2';
       refreshCreds.User_Name__c='test@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;
 
       OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
       //set the selected org to first one.
       setUpCtrl.selectedOrg='Test Class Created Org 1';
       System.assertEquals(setUpCtrl.getDefinedUserNames().size(),1);

       System.assertEquals(setUpCtrl.getDefinedUserNames().get(0).getLabel(),'testclass@username.com');

        //set the selected org to first one.
       setUpCtrl.selectedOrg='Test Class Created Org 2';
       System.assertEquals(setUpCtrl.getDefinedUserNames().size(),1);
       System.assertNotEquals(setUpCtrl.getDefinedUserNames().get(0).getLabel(),'testclass@username.com');
       System.assertEquals(setUpCtrl.getDefinedUserNames().get(0).getLabel(),'test@username.com');
    }

    @isTest static void testmodifyOauth() {
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        setUpCtrl.modifyOauthDetails();
        System.assertEquals(setUpCtrl.modifyOauth,true);
        //call cancel and see the modify flag is reset
        setUpCtrl.cancel();
        System.assertEquals(setUpCtrl.modifyOauth,false);
        
    }

    @isTest static void testmodifyOrgDetails() {
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        setUpCtrl.modifyOrgDetails();
        System.assertEquals(setUpCtrl.modifyOrgInfo,true);
        //call cancel and see the modify flag is reset
        setUpCtrl.cancel();
        System.assertEquals(setUpCtrl.modifyOrgInfo,false);
    }

    @isTest static void testauthenticateUser() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;
        //set the org name
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014

        refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        refreshProfile.Name='Test Class Created Org 2';
        insert refreshProfile;

        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        setUpCtrl.selectedOrg='Test Class Created Org 2';
        PageReference pageRef=setUpCtrl.authenticateUser();
        //construct the expected URL
        String responseTypeStr='?response_type=code&client_id=aaaaa';
        String redirect_uri='&redirect_uri=' + EncodingUtil.urlEncode('https://test.callback.com', 'UTF-8');

        String expectedURL='https://test.com/services/oauth2/authorize' + responseTypeStr + redirect_uri + '&display=page&immediate=false';

        PageReference expectedPageRef=new PageReference(expectedURL);
        expectedPageRef.setRedirect(true);
        
        //validate pageRef value
        System.assertEquals(expectedPageRef.getUrl(),pageRef.getUrl());
    


        PA_Onboarding_Property__c paOnboarding=PA_Onboarding_Property__c.getInstance('Authenticating_OrgName__c');

        System.assertEquals(paOnboarding.Value__c,'Test Class Created Org 2');
        
        //test the reload of authenticated user name
        setUpCtrl=new OrgRefresh_SetupController();
        System.assertEquals(setUpCtrl.selectedOrg,'Test Class Created Org 2');
        setUpCtrl.authenticateUser();

    }

    @isTest static void testSave() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        
        //use the save method in the controller to do the actual save to DB. let's test invalid cases first
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        //update username password flow to true , but clear out username.
        refreshProfile.UserNamePwd_Flow__c=true;
        refreshProfile.userName__c='';
        setUpCtrl.userName='';
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        //set the authflow selected value
        setUpCtrl.authFlowSelected=true;
        //set the refresh profile instance
        setUpCtrl.refreshProfInstance=refreshProfile;
      
        setUpCtrl.save();

        //assert the flags
        System.assertEquals(setUpCtrl.oauthDefined,false);
        System.assertEquals(setUpCtrl.orgSettingsDefined,false);
        System.assertEquals(setUpCtrl.canFetchData,false);
        System.assertEquals(setUpCtrl.getHasMessages(),true);

        //update autorefresh as false, but don't specify start and end dates.
        refreshProfile.Auto_Refresh__c=false;
        refreshProfile.userName__c='testuser@username.org';
        setUpCtrl.userName='testuser@username.org';
        //set the refresh profile instance
        setUpCtrl.refreshProfInstance=refreshProfile;
    
        setUpCtrl.save();

        //assert the flags
        System.assertEquals(setUpCtrl.oauthDefined,true);
        System.assertEquals(setUpCtrl.orgSettingsDefined,false);
        System.assertEquals(setUpCtrl.canFetchData,false);
        System.assertEquals(setUpCtrl.getHasMessages(),true);

        //update autorefresh as true. Let the save go through this time
        refreshProfile.Auto_Refresh__c=true;
        refreshProfile.userName__c='testuser@username.org';
        setUpCtrl.userName='testuser@username.org';
        //set the refresh profile instance
        setUpCtrl.refreshProfInstance=refreshProfile;
    
        
        setUpCtrl.save();

        //assert the flags
        System.assertEquals(setUpCtrl.oauthDefined,true);
        System.assertEquals(setUpCtrl.orgSettingsDefined,true);
        System.assertEquals(setUpCtrl.canFetchData,true);

        //update username password flow as false, but don't have the refresh token populated.
        refreshProfile.UserNamePwd_Flow__c=false;
        //also reset the authflow selected value.
        setUpCtrl.authFlowSelected=false;
        refreshProfile.Refresh_Token__c='';
        refreshProfile.userName__c='testuser@username.org';
        setUpCtrl.userName='testuser@username.org';
        //set the refresh profile instance
        setUpCtrl.refreshProfInstance=refreshProfile;
    
        
        setUpCtrl.save();

        //assert the flags
        System.assertEquals(setUpCtrl.oauthDefined,true);
        System.assertEquals(setUpCtrl.orgSettingsDefined,true);
        System.assertEquals(setUpCtrl.canFetchData,false);

        //save should go through fine this time
        refreshProfile.UserNamePwd_Flow__c=false;
        refreshProfile.Refresh_Token__c='test_refresh_token';
        refreshProfile.userName__c='testuser@username.org';
        setUpCtrl.userName='testuser@username.org';
        //set the refresh profile instance
        setUpCtrl.refreshProfInstance=refreshProfile;
    
        setUpCtrl.save();

        setUpCtrl.updateAuthFlowFields();

        //assert the flags
        System.assertEquals(setUpCtrl.oauthDefined,true);
        System.assertEquals(setUpCtrl.orgSettingsDefined,true);
        System.assertEquals(setUpCtrl.canFetchData,true);


    }
    @isTest static void testScheduleRefresh() {
        
        PA_Onboarding_Property__c propertyInstance=OrgRefresh_PrepTestData.createPAOnboardingSelectedOrg('Test Class Created Org');
        insert propertyInstance;
        
        
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        

        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
        setUpCtrl.startFetchJob();
         Test.stopTest();
    }

    @isTest static void testScheduleUserNamePwd() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
        insert refreshProfile;

        Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='Test Class Created Org';
       refreshCreds.User_Name__c='testclass@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;

        Test.startTest(); 

        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        //mock as if canfetchdata is true.
        setUpCtrl.canFetchData=true;
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        
        setUpCtrl.startFetchJob();
        
       Test.stopTest();
    }

    
    

    @isTest static void testScheduleRefreshWithouRefreshProf() {
        
        Test.startTest(); 
        
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        setUpCtrl.scheduleRefresh();
       
        setUpCtrl.cancel();
        Test.stopTest();
    }

     

    @isTest static void testFetchAccessToken() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;

        Test.startTest(); 

        ApexPages.currentPage().getParameters().put('code', 'yyyy');
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        
        setUpCtrl.fetchAccessToken();
        
       Test.stopTest();
    }

    @isTest static void testOnDemandRefreshNegativeCase() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_WEBFLOW);
        insert refreshProfile;

        Test.startTest(); 

        ApexPages.currentPage().getParameters().put('code', 'yyyy');
        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        
        setUpCtrl.onDemandRefresh();
        
       Test.stopTest();
    }

    @isTest static void testOnDemandRefresh() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
        insert refreshProfile;

        Test.startTest(); 

        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        //mock as if canfetchdata is true.
        setUpCtrl.canFetchData=true;
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        
        setUpCtrl.onDemandRefresh();
        
       Test.stopTest();
    }

    @isTest static void testOnDemandRefreshUserNamePassword() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
        insert refreshProfile;

        Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='Test Class Created Org';
       refreshCreds.User_Name__c='testclass@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;

        Test.startTest(); 

        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        //mock as if canfetchdata is true.
        setUpCtrl.canFetchData=true;
        Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());
          //set the selected org name
        setUpCtrl.selectedOrg='Test Class Created Org';
        
        setUpCtrl.onDemandRefresh();
        
       Test.stopTest();
    }

     @isTest static void testOnChangeOrg() {
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
        insert refreshProfile;

        Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='Test Class Created Org';
       refreshCreds.User_Name__c='testclass@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;

        OrgRefresh_SetupController setUpCtrl=new OrgRefresh_SetupController();
        setUpCtrl.selectedOrg='Test Class Created Org';
        setUpCtrl.changeOrg();

        System.assertEquals(true,setUpCtrl.authFlowSelected);
        System.assertEquals('testclass@username.com',setUpCtrl.userName);

     }


    
}