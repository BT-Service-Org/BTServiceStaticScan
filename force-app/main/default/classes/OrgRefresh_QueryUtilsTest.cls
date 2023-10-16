@isTest
private class OrgRefresh_QueryUtilsTest {
    
    @isTest static void testOrgNameMethods() {
        // Implement test code
        //OrgRefresh_QueryUtils.setOrgName('Test Class Org Name');
        OrgRefresh_QueryUtils.setOrgAppName('Test Class Org Name'); // Updated by SD - 06/24/2014
        //call the get method to asset the value has been set.
        //System.assertEquals(OrgRefresh_QueryUtils.getOrgName(),'Test Class Org Name');
        System.assertEquals(OrgRefresh_QueryUtils.getOrgAppName(),'Test Class Org Name'); // Updated by SD - 06/24/2014
    }
    
    @isTest static void testgetRefreshProfile() {
        // Implement test code
        //call the utility method to insert the refresh profile for the refresh token flow
        Org_Refresh_Profile__c orgRefreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
        insert orgRefreshProfile;
        //call the method to fetch refresh token. Cache parameter is set to true. However, there would not be any value in the cache.
        //ORG_NAME has not been set. Hence an exception should be thrown.
        try{
            //Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
            Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile();
        }
        catch(OrgRefresh_SettingsUndefinedException e){
            System.assertEquals(e.getMessage(),'ORG_APP_NAME of interest is not set.');
        }
        //lets set the org name now. However the org name is not matching the inserted record. 
        //Hence an exception related to that should be thrown.
        //OrgRefresh_QueryUtils.setOrgName('Test Class Org Name');
        OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Update by SD - 06/24/2014
        try{
            //Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
            Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(); // Updated by SD - 06/24/2014
        }
        catch(OrgRefresh_SettingsUndefinedException e){
            System.assertEquals(e.getMessage(),'Settings is not defined for CertOrg_Cert');
        }

        //lets set the correct org name now
        //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
        OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
        //Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(true);
        Org_Refresh_Profile__c refreshProfile=OrgRefresh_QueryUtils.getRefreshProfile(); // Updatedb y SD - 06/24/2014
        //it should succeed this time. assert the refresh profile values.
        System.assertEquals(refreshProfile.Endpoint__c,'https://test.com');
        System.assertEquals(refreshProfile.Consumer_Key__c,'aaaaa');
        System.assertEquals(refreshProfile.Consumer_Secret__c,'bbb');

        System.assertNotEquals(refreshProfile.UserNamePwd_Flow__c,true);
        System.assertNotEquals(refreshProfile.username__c,'test@username.com');
   }

   @isTest static void testValidateEnum(){
      OrgRefresh_AuthFlows authflow=OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN;
      //different auth flows should return false
      System.assertEquals(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_WEBFLOW),false);
      //same auth flow. Should return true.
      System.assertEquals(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN),true);
      //we don't compare nulls
      System.assertEquals(OrgRefresh_QueryUtils.validateEnum(null, null),false);
      //null and a valid auth flow should return false.
      System.assertEquals(OrgRefresh_QueryUtils.validateEnum(null, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN),false);
   }


   @isTest static void testFetchCertData(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
    refreshProfile.Last_Refreshed__c=System.now();
      insert refreshProfile;


        
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
        
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());

      //call the method to fetch data
      Test.startTest();
      OrgRefresh_QueryUtils.fetchData('test_access_token','CertOrg_Cert');
    //  OrgRefresh_QueryUtils.fetchData('test_access_token','Test Class Created Org');
      Test.stopTest();

      //query and check if the certification data is inserted against the contacts as in the mock response.
      List<Certification_Data__c> certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser1@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),8);

      certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser2@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),5);


   }

   
   @isTest static void testAuthenticateandFetchUserName(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.USERNAME_PASSWORD);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
      insert refreshProfile;

       //insert into the org refresh cred object to store the password and user name for the specified org. Password is stored as encrypted field.
       Org_Refresh_Creds__c refreshCreds=new Org_Refresh_Creds__c();
       //set the name field to be org name
       refreshCreds.Name='CertOrg_Cert';
       refreshCreds.User_Name__c='testclass@username.com';
       refreshCreds.Password__c='dummypassword';
       insert refreshCreds;
    
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
    
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());

      //call the method to fetch data
      Test.startTest();
      OrgRefresh_QueryUtils.authenticateandFetch(OrgRefresh_AuthFlows.USERNAME_PASSWORD.name(),'CertOrg_Cert','testclass@username.com');
      Test.stopTest();

      //query and check if the certification data is inserted against the contacts as in the mock response.
      List<Certification_Data__c> certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser1@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),8);

      certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser2@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),5);


   }

    @isTest static void testAuthenticateandFetchOauth(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
      insert refreshProfile;

     
    
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
    
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());

      //call the method to fetch data
      Test.startTest();
      OrgRefresh_QueryUtils.authenticateandFetch(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN.name(),'CertOrg_Cert','test@username.com');
      Test.stopTest();

      //query and check if the certification data is inserted against the contacts as in the mock response.
      List<Certification_Data__c> certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser1@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),8);

      certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser2@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),5);


   }

   @isTest static void testFetchCertDataGivenStartDateAndEndDate(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileDataWithStartAndEnd(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
      insert refreshProfile;


        
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
        
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertFetchIncomplete());

      //call the method to fetch data
      Test.startTest();
      OrgRefresh_QueryUtils.fetchData('test_access_token','CertOrg_Cert');
      OrgRefresh_QueryUtils.fetchData('test_access_token','CertOrg_Cert');
      
      Test.stopTest();

      //query and check if the certification data is inserted against the contacts as in the mock response.
      List<Certification_Data__c> certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser1@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),8);

      certificationDataRec=[select   Certification_Status__c
                                                               , Certification_Type_Name__c
                                                               , Contact__r.Email
                                                               , Original_Certification_Date__c
                                                         from Certification_Data__c
                                                         where Contact__r.Email='testclassuser2@test.org'
                                                       ];
      //assert the number of records
      System.assertEquals(certificationDataRec.size(),5);


   }
   
   
   @isTest static void testExecuteBulkUpdate(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
    refreshProfile.Last_Refreshed__c=System.now();
      insert refreshProfile;


        
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockBulkUpdateTest());
      
      String bodyStr1 = '<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload"><operation>update</operation><object>Contact</object><contentType>XML</contentType></jobInfo>';
        
        String bodyStr2 = '<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload"> <sObject><Id>0033000000NEW5BAAX</Id><Next_Available_Date__c>2015-08-19+/-0000</Next_Available_Date__c></sObject></sObjects>';

      //call the method to update org62
      Test.startTest();
      String myresults = OrgRefresh_QueryUtils.executeBulkUpdate('https://test.refreshtoken.com', 'test_access_token', 'services/async/30.0/job', bodyStr1, bodyStr2, 'XML');//fetchData('test_access_token','Test Class Created Org');

      Test.stopTest();

      // validate the response from the execute contains what we wanted (myresults)
      String[] results = myresults.split('\n');
      String[] highlevelResults;
      Integer foundCount = 0;
      Integer recNum = 0;
      
      for (String a : results) {
        if (a.contains(' - ')) {
            highlevelResults = a.split(' - ');
            if (foundCount == 0) {
                    // created job
                    System.assertEquals(highlevelResults[0], '201');
                    System.assertEquals(highlevelResults[1], 'Created');
            } else if (foundCount == 1) {
                    // created batch
                    System.assertEquals(highlevelResults[0], '201');
                    System.assertEquals(highlevelResults[1], 'Created');
            } else if (foundCount == 2) {
                    // closed job
                    System.assertEquals(highlevelResults[0], '200');
                    System.assertEquals(highlevelResults[1], 'OK');
            } else if (foundCount == 3) {
                    // got status
                    System.assertEquals(highlevelResults[0], '200');
                    System.assertEquals(highlevelResults[1], 'OK');
            }       
            
            foundCount++;
        }
        if (foundCount == 4) {
            break; // exit loop & save results record number
        }
        recNum++; // increment counter to keep track of which record we're looking at
        
      }
      
      // assert the status codes, and the end result
      String perrecResult = results[recNum+1];
      System.debug(perrecResult);
      System.debug('7777777777777777777777777777777777777777');
      System.debug(results[recNum]);
      
      System.assert(perrecResult.contains('<statusCode>'));


   }
    
    @isTest static void testExecuteUpdate(){
      //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
    refreshProfile.Last_Refreshed__c=System.now();
      insert refreshProfile;


        
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('Test Class Created Org'); // Updated by SD - 06/24/2014
        
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockUpdateTest());
        
        String bodyStr = '{"Id":"ABCXYZ", "Next_Available_Date__c":"2014/08/12"}';
        
      Test.startTest();
      String myresults = OrgRefresh_QueryUtils.executeUpdate('https://test.refreshtoken.com', 'test_access_token', 'services/async/30.0/job', bodyStr);//fetchData('test_access_token','Test Class Created Org');

      Test.stopTest();

      // validate the response from the execute contains what we wanted (myresults)
      String[] results = myresults.split('\n');
      String[] highlevelResults = results[0].split(' - ');

      System.assertEquals(highlevelResults[0], '204');
      System.assertEquals(highlevelResults[1], 'No Content');
            
        
    }
    
    @isTest static void testgetOrgAppArray() {
        Test.startTest();
        String[] myresults1 = OrgRefresh_QueryUtils.getOrgAppArray('Testing_ABC123');
        String[] myresults2 = OrgRefresh_QueryUtils.getOrgAppArray('TestingABC123');
        String[] myresults3 = OrgRefresh_QueryUtils.getOrgAppArray('Test_ing_ABC_123');
        Test.stopTest();
        System.assertEquals(myresults1.size(), 2);
        System.assertEquals(myresults1[0], 'Testing');
        System.assertEquals(myresults1[1], 'ABC123');
        System.assertEquals(myresults2, null);
        System.assertEquals(myresults3, null);
    }
    
    @isTest static void testgetOrgName() {
        Test.startTest();
        String myresults = OrgRefresh_QueryUtils.getOrgName('Testing_ABC123');
        Test.stopTest();
        System.assertEquals(myresults, 'Testing');
    }
    
    @isTest static void testgetAppName() {
        Test.startTest();
        String myresults = OrgRefresh_QueryUtils.getAppName('Testing_ABC123');
        Test.stopTest();
        System.assertEquals(myresults, 'ABC123');
    }
    
    @isTest static void testgetBatchInstance() {
        Test.starttest();
        OrgRefresh_BatchInterface myresults = OrgRefresh_QueryUtils.getBatchInstance('CertOrg_Cert');
        test.stoptest();
        System.assertNotEquals(myresults, null);
        
    }
    
    @isTest static void testfetchUserIdbyName() {
         //insert pa onboarding, candidate and contact records.
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user1','testclassuser1@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user2','testclassuser2@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user3','testclassuser3@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user4','testclassuser4@test.org');
      OrgRefresh_PrepTestData.createPAOnboardingandRelated('Test class user5','testclassuser5@test.org');
      
      //create the refresh profile
      Org_Refresh_Profile__c refreshProfile=OrgRefresh_PrepTestData.createRefreshProfileData(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN);
       //set the other params as needed, as if a valid auth was done.
      refreshProfile.Access_Token__c='test_access_token';
      refreshProfile.Instance_URL__c='https://test.refreshtoken.com';
      refreshProfile.Refresh_Token__c='test_refresh_token';
      insert refreshProfile;

     
    
      //OrgRefresh_QueryUtils.setOrgName('Test Class Created Org');
      OrgRefresh_QueryUtils.setOrgAppName('CertOrg_Cert'); // Updated by SD - 06/24/2014
    
       
      Test.setMock(HttpCalloutMock.class, new OrgRefresh_MockCertDataFetchTest());

      //call the method to fetch data
      Test.startTest();
      Id resultUserId = OrgRefresh_QueryUtils.fetchUserIdbyName(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN.name(), 'test@username.com');
          //authenticateandFetch(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN.name(),'CertOrg_Cert','test@username.com');
      Test.stopTest();
        
        System.assertEquals(resultUserId, null); // CJT because not using a proper response from the mock service call!!!
        
    }
}