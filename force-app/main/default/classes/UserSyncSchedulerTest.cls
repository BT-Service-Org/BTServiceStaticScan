@isTest(seealldata=false)
public class UserSyncSchedulerTest {
  
  Static final String PROG_MGR = 'Program Manager';
  
  /**
     @description : Test data setup for CSG Group, CSG ProfileSkill and GroupSkill    
     @param  - none 
    */
  @testsetup
  public static void loaddata() {
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
    System.assertNotEquals(testPaOnboardingPropertyList.size(), 0,'List should not be 0');
  }

  @isTest
  public static void testSchedulingOfBatchUser1() {
    Account a = new Account(Name = 'Salesforce.com - DO NOT TOUCH');
    insert a;
    String hostname = '@sfservices.com.qa'; //swap out for prod
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String uid = h.SubString(0, 8);
    User testUser = new User(
      Alias = uid,
      Email = uid + hostname,
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/New_York',
      UserName = uid + hostname,
      Org62Id__c = '0054V00000E8q8NQAR',
        is_SSO_User__c = true ,
        FederationIdentifier = 'testingFedId'
    );
    insert testUser;
      
      List<User__x> users = new List<User__x>();
    User__x user = new User__x(FirstName__c= 'test',
                               LastName__c='lname',
                               Title__c= 'Mr',
                               Username__c= 'test@sdf.com',
                               Email__c= 'abc@hh.com',
                               externalId= '0054V00000E8q8NQAR',
                               IsActive__c = true
                              );
        users.add(user);
      user = new User__x(FirstName__c= 'test 1',
                               LastName__c='lname 1',
                               Title__c= 'Mr',
                               Username__c= 'test2@sdf2.com',
                               Email__c= 'abc2@hh2.com',
                               IsActive__c = true
                              );
      
      
      
    users.add(user);
    ObjectManagerMock.setMock(new MockinterfaceOverride(users));
    Test.startTest();

      
      
    List<User__x> lst = new List<User__x>();

    List<Sobject> sobjectlst = new List<Sobject>();
    sObject uSobject = Schema.getGlobalDescribe().get('User__x').newSObject();
 
      
    String jobId = '';
    Date nextDay = System.today().addDays(1);
    Integer year = nextDay.year();
    Integer month = nextDay.month();
    Integer day = nextDay.day();
    String cronExp = '0 0 0 ' + day + ' ' + month + ' ? ' + year; // schedule for midnight next day.

   
    jobId = System.schedule('Test Sharing Recalc Batch Schedule', cronExp, new UserSyncScheduler());
    Test.stopTest();
    Map<String, List<UserSync__mdt>> config = OrgRefresh_Util.getCommunities();
    
    if (config?.size() > 0 && config.get(PROG_MGR) != null) {
      String query = new UserSyncScheduler().buildQuery(config.get(PROG_MGR), true);
      System.assertNotEquals(query, null,'Query should not be null');
      query = new UserSyncScheduler().buildQuery(config.get(PROG_MGR), false);
      System.assertNotEquals(query, null,'Query should not be null');
    }
  } 
}