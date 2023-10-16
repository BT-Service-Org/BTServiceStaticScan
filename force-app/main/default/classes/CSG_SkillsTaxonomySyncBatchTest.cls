/*
Apex class Name : CSG_SkillsTaxonomySyncBatchTest
Description		: Test class for CSG_SkillsTaxonomySyncBatch
Created Date	: May 11, 2022  
*/
@isTest(SeeAllData=false)
public class CSG_SkillsTaxonomySyncBatchTest {
  public static final String TESTCAT = 'Test cat';
  public static final String TESTDESC = 'Test desc';
  public static final String TESTCOMMUNITY = 'Test community';
  /**
     @description : Test data setup for CSG Group, CSG ProfileSkill and GroupSkill    
     @param  - none 
    */
  @testsetup
  public static void loadData() {
    Account a = new Account(Name = 'Salesforce.com - DO NOT TOUCH');
    insert a;

    List<CSG_Group__c> groupList = new List<CSG_Group__c>();

    CSG_Group__c groupVal = new CSG_Group__c();
    groupVal.Name = 'Program Architect';
    groupList.add(groupVal);
    insert groupList;

    List<CSGProfileSkill__c> profSkillList = new List<CSGProfileSkill__c>();
    CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
    profileVal.Category__c = TESTCAT;
    profileVal.Description__c = TESTDESC;
    profileVal.CSG_Community__c = TESTCOMMUNITY;
    profileVal.External_Id__c = 'a4V3C00000014hWUAQ';
    profSkillList.add(profileVal);
    insert profSkillList;

    List<CSG_Group_Skill__c> profSkillGroupList = new List<CSG_Group_Skill__c>();
    CSG_Group_Skill__c profileSkillVal = new CSG_Group_Skill__c();
    profileSkillVal.CSGProfileSkill__c = profSkillList[0].id;
    profileSkillVal.CSG_Group__c = groupList[0].id;
    profSkillGroupList.add(profileSkillVal);

    insert profSkillGroupList;

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

    List<ProfileSkillTax__x> profSkillTaxList = new List<ProfileSkillTax__x>();
    ProfileSkillTax__x profileTaxVal = new ProfileSkillTax__x();
    profileTaxVal.Category_c__c = TESTCAT;
    profileTaxVal.Description__c = TESTDESC;
    profileTaxVal.Name__c = TESTCOMMUNITY;
    profileTaxVal.ExternalId = 'a4V3C00000014hWUAR';
    profileTaxVal.Sub_Category_c__c = '';
    profileTaxVal.Last_Modified_Date__c = datetime.now();
    profileTaxVal.ExternalId = '';
    profileTaxVal.ProfileSkillTaxId__c = '';
    profSkillTaxList.add(profileTaxVal);
  }

  /**
     @description : Test data setup for User
     @return : User
     @param  - none 
    */
  public static User createUser() {
    String hostname = '@sfservices.com.skdev';
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
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
      UserName = uid + hostname
    );
    insert testUser;
    return testUser;
  }

  /**
     @description : Test the batch class to update Skills Taxonomy
     @param  - none 
    */
  @isTest
  static void submitRecordsUpdate() {
    User testUser = createUser();

    System.runAs(testUser) {
      Test.startTest();

      List<ProfileSkillTax__x> profSkillTaxList = new List<ProfileSkillTax__x>();
      //This is an existing CSG Profileskill record with matching external id
      ProfileSkillTax__x profileTaxVal = new ProfileSkillTax__x();
      profileTaxVal.Category_c__c = TESTCAT;
      profileTaxVal.Description__c = TESTDESC;
      profileTaxVal.Name__c = TESTCOMMUNITY;
      profileTaxVal.Sub_Category_c__c = '';
      profileTaxVal.Last_Modified_Date__c = datetime.now();
      profileTaxVal.ExternalId = 'a4V3C00000014hWUAR';
      profileTaxVal.ProfileSkillTaxId__c = '';
      profSkillTaxList.add(profileTaxVal);

      //This is a new CSG Profileskill record with new external id
      profileTaxVal = new ProfileSkillTax__x();
      profileTaxVal.Category_c__c = TESTCAT;
      profileTaxVal.Description__c = TESTDESC;
      profileTaxVal.Name__c = TESTCOMMUNITY;
      profileTaxVal.Sub_Category_c__c = '';
      profileTaxVal.Last_Modified_Date__c = datetime.now();
      profileTaxVal.ExternalId = 'a4V3C00000014hWUAS';
      profileTaxVal.ProfileSkillTaxId__c = '';
      profSkillTaxList.add(profileTaxVal);

      CSG_SkillsTaxonomySyncBatch invokeBatch = new CSG_SkillsTaxonomySyncBatch();

      invokeBatch.start(null);
      invokeBatch.execute(null, profSkillTaxList);
      invokeBatch.finish(null);
      string isSuccess = invokeBatch.performExecution(profSkillTaxList);

      System.assertEquals(isSuccess, 'success', 'Fail');
      Test.stopTest();
    }
  }
}