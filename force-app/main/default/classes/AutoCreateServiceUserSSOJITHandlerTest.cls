/**
 * Author(s): Skills360 Team
 * @description: Test class for AutoCreateServiceUserSSOJITHandler
 * CreatedDate: 2022, Sep 20
 */
@isTest
public class AutoCreateServiceUserSSOJITHandlerTest {
  /**
     @description : Test data for PA_Onboarding_Property__c
     @param  - none 
    */
  @testsetup
  public static void loadData() {
    List<PA_Onboarding_Property__c> testPaOnboardingPropertyList = new List<PA_Onboarding_Property__c>();

    PA_Onboarding_Property__c testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
    testPaOnboardingPropertyList.add(testPaOnboardingProperty);
    testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
    testPaOnboardingProperty.Name = 'MuleSoft Template Onboarding Id';
    testPaOnboardingPropertyList.add(testPaOnboardingProperty);

    testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
    testPaOnboardingProperty.Name = 'SC Template Onboarding Id';
    testPaOnboardingPropertyList.add(testPaOnboardingProperty);

    insert testPaOnboardingPropertyList;
    System.assertNotEquals(testPaOnboardingPropertyList.size(), 0);
  }

  @isTest
  static void testCreateAndUpdateUser() {
    AutoCreateServiceUserSSOJITHandler handler = new AutoCreateServiceUserSSOJITHandler();
    Auth.UserData sampleData = new Auth.UserData(
      'testId',
      'testFirst',
      'testLast',
      'testFirst testLast',
      'testuser@example.org',
      null,
      'testuserlong',
      'en_US',
      'facebook',
      null,
      new Map<String, String>{ 'language' => 'en_US' }
    );
    //String pid =[Select Id from Profile Where name ='CSG '].Id ;
    Map<string, String> tempUser = new Map<String, String>{
      'language' => 'en_US',
      'lastName' => 'asdjhgasjhd',
      'firstName' => 'firstNametest',
      'email' => 'askdasgdhgas@sdjkfd.com',
      'alias' => 'asdhagsd',
      'TimeZoneSidKey' => 'America/Los_Angeles',
      'LocaleSidKey' => 'en_US',
      'EmailEncodingKey' => 'UTF-8',
      'LanguageLocaleKey' => 'en_US',
      'title' => 'MTS',
      'department' => 'testDept'
    };

    Account acc = new Account();
    acc.Name = 'Salesforce.com - DO NOT TOUCH';
    insert acc;

    System.runAs(new user(id = userinfo.getuserid())) {
      Test.startTest();
      User u = handler.createUser(null, null, null, '', tempUser, null);

      insert (u);
      String uid = u.id;

      sampleData = new Auth.UserData(
        'testNewId',
        'testNewFirst',
        'testNewLast',
        'testNewFirst testNewLast',
        'testnewuser@example.org',
        null,
        'testnewuserlong',
        'en_US',
        'facebook',
        null,
        new Map<String, String>{}
      );
      handler.updateUser(uid, null, null, null, '', tempUser, null);

      User updatedUser = [
        SELECT userName, email, firstName, lastName, alias
        FROM user
        WHERE id = :uid
      ];

      tempUser = new Map<String, String>{
        'language' => 'en_US',
        'lastName' => 'asdjhgasjhd',
        'email' => 'askdasgdhgas@sdjkfdtest.com',
        'TimeZoneSidKey' => 'America/Los_Angeles',
        'LocaleSidKey' => 'en_US',
        'EmailEncodingKey' => 'UTF-8',
        'LanguageLocaleKey' => 'en_US',
        'title' => 'MTS',
        'department' => 'testDept'
      };

      u = handler.createUser(null, null, null, '', tempUser, null);
      System.assertNotEquals(updatedUser.id, null);
      Test.stopTest();
    }

  }
}