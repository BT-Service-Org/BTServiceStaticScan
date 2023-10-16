/**
Class Name : CSG_SkillsTaxonomySyncSchedulerClsTest
@description		: Test class for CSG_SkillsTaxonomySyncSchedulerCls
*/
@isTest(SeeAllData=false)
public class CSG_SkillsTaxonomySyncSchedulerClsTest {
  public static final String PARCHITECTSTR = 'Program Architect';
  /**
    @description : loadData
    */
  @testsetup
  public static void loadData() {
    List<CSG_Group__c> groupList = new List<CSG_Group__c>();

    CSG_Group__c groupVal = new CSG_Group__c();
    groupVal.Name = PARCHITECTSTR;
    groupVal.Level_1__c = 'Enablement';
    groupVal.Level_2__c = 'Salesforce Skills';
    groupVal.Level_3__c = 'CES - Difficult Conversations';
    groupList.add(groupVal);
    CSG_Group__c groupVal1 = new CSG_Group__c();
    groupVal1.Name = 'Test';
    groupList.add(groupVal1);
    CSG_Group__c groupVal2 = new CSG_Group__c();
    groupVal2.Name = 'Test1';
    groupVal.Level_1__c = 'Enablement';
    groupList.add(groupVal2);
    insert groupList;

    List<CSGProfileSkill__c> profSkillList = new List<CSGProfileSkill__c>();
    CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
    profileVal.Category__c = 'Test cat';
    profileVal.Description__c = 'Test desc';
    profileVal.CSG_Community__c = 'Test community';
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

    Account acc = new Account();
    acc.Name = 'Salesforce.com - DO NOT TOUCH';
    insert acc;
  }
  /**
@description : createUser
@return      : User
*/
  public static User createUser() {
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
      CSG_SkillsTaxonomySyncSchedulerCls abc = new CSG_SkillsTaxonomySyncSchedulerCls();
      abc.execute(null);
      CSG_Group__c csgRec = [SELECT Id FROM CSG_Group__c LIMIT 1];
      System.assertNotEquals(csgRec, null, ' ');
      Test.stopTest();
    }
  }
}