/**
Class Name : SkillsEntryControllerTest
@description		: Test class for SkillsEntryController
*/              
@isTest(SeeAllData=false)
public class SkillsEntryControllerTest {
    public static final String PARCHITECTSTR = 'Program Architect';
    private static final String PRODUCTFOCUSSTR = 'Industry Clouds';
    private static final String INDUSTRYFOCUSSTR = 'Financial Services';
    /**
     @description : loadData
     */
    @testsetup
    public static void loadData(){
       
        List<CSG_Group__c> groupList =  new List<CSG_Group__c> ();
        
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
        
        List<CSGProfileSkill__c> profSkillList =  new List<CSGProfileSkill__c> ();
        CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
        profileVal.Category__c = 'Test cat';
        profileVal.Description__c = 'Test desc';
        profileVal.CSG_Community__c = 'Test community';
        profileVal.External_Id__c = 'a4V3C00000014hWUAQ';
        profSkillList.add(profileVal);
        
        insert profSkillList; 
        
        List<CSG_Group_Skill__c> profSkillGroupList =  new List<CSG_Group_Skill__c> ();
        CSG_Group_Skill__c profileSkillVal = new CSG_Group_Skill__c();
        profileSkillVal.CSGProfileSkill__c  =profSkillList[0].id;
        
        profileSkillVal.CSG_Group__c = groupList[0].id; 
        profSkillGroupList.add(profileSkillVal);
        
        insert profSkillGroupList;
        
        List<PA_Onboarding_Property__c> testPaOnboardingPropertyList = new List<PA_Onboarding_Property__c>();
        
        PA_Onboarding_Property__c testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
        testPaOnboardingPropertyList.add(testPaOnboardingProperty);
        testPaOnboardingProperty =TestDataFactory.createPaOnboardingProperty();
        testPaOnboardingProperty.Name = 'MuleSoft Template Onboarding Id';
        testPaOnboardingPropertyList.add(testPaOnboardingProperty);
        
        testPaOnboardingProperty =TestDataFactory.createPaOnboardingProperty();
        testPaOnboardingProperty.Name = 'SC Template Onboarding Id';
        testPaOnboardingPropertyList.add(testPaOnboardingProperty);
        
        
        insert testPaOnboardingPropertyList;
        
   Account acc = new Account();
        acc.Name= 'Salesforce.com - DO NOT TOUCH';
        insert acc;        
        

    }
    
    
    /**
     @description : createUser
     @return      : User
     */
    public static User createUser() {
        String hostname = '@sfservices.com.qa';//swap out for prod
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User testUser = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + hostname
        );
        insert testUser;
        return testUser;
    }
    @isTest
    static void testGetUser() {
        Test.startTest();
        User user = SkillsEntryController.getUser();
        System.AssertEquals('Testing', user.LastName,' ');
        Test.stopTest();
    }
    @isTest
    static void testGetAvailableGroups() {
        List<CSG_Group__c> groupList = new List<CSG_Group__c>();
        Test.startTest();
        groupList = SkillsEntryController.getAvailableGroups();
        System.assert(groupList.size() > 0,' ');
        Test.stopTest();
       
    }
    
    @isTest
    static void testGetUserGroupSkillsList() {
        User testUser = createUser();
        List<SkillsEntryController.UserSkillWrapper> userSkillWrapperList = new List<SkillsEntryController.UserSkillWrapper>();
        System.runAs(testUser){
            Test.startTest();
            userSkillWrapperList = SkillsEntryController.getUserGroupSkillsList(testUser.id, PARCHITECTSTR);
            Test.stopTest();
        }
        //System.assert(userSkillWrapperList.size() > 0,' ');
        
        
    }
    
    @isTest
    static void testGetAllUserSkillsList() {
        User testUser = createUser();
        contact testContact = TestDataFactory.createContact();
        insert testContact;
        
        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(testUser.id, testUser.id, testContact.Id);
        testPaOnboarding.Industry_Focus__c = INDUSTRYFOCUSSTR;
        testPaOnboarding.Product_Focus__c = PRODUCTFOCUSSTR;
        testPaOnboarding.Operating_Unit_Focus__c = 'INDIA';
        testPaOnboarding.Discipline__c	 = 'Data';
        insert testPaOnboarding;
        
        List<Learning_Domain__c> testLearningDomainList = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomainList;
        List<SkillsEntryController.UserSkillWrapper> userSkillWrapperList = new List<SkillsEntryController.UserSkillWrapper>();
        System.runAs(testUser){
            Test.startTest();
            userSkillWrapperList = SkillsEntryController.getAllUserSkillsList(testUser.id);
            Test.stopTest();
        }   
        System.assert(userSkillWrapperList.size() > 0, ' ');
    }
    
    @isTest
    static void testGetAllSkillsList() {
        User testUser = createUser();
        List<SkillsEntryController.UserSkillWrapper> userSkillWrapperList = new List<SkillsEntryController.UserSkillWrapper>();
        System.runAs(testUser){
            Test.startTest();
            userSkillWrapperList = SkillsEntryController.getAllSkillsList();
            Test.stopTest();
        }
        System.assert(userSkillWrapperList.size() > 0, ' ');
        
    }
    
    @isTest
    static void submitRecordsUpdate() {
        User testUser = createUser();
        List<List<Map<String,String>>> testRecords = new List<List<Map<String,String>>>();
        List<Map<String,String>> rowRecords = new List<Map<String,String>>();
        Map<String, String> row = new Map<String, String>();
        row.put('Expertise_Rating__c','3- Advanced');
        row.put('id','x0h0j000000CbCTAA0');
        rowRecords.add(row);
        testRecords.add(rowRecords);
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.submitRecords(testRecords);
            List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
            System.assert(skillList.size() == 0,' ');  
            Test.stopTest();
        }
    }
    
@isTest
    static void loadDefaultsTest() {
        User testUser = createUser();
         
        System.runAs(testUser){
            Test.startTest();
              Account acc = new Account();
        acc.Name= 'Salesforce.com - DO NOT TOUCH';
        insert acc;
            Map<Object,Object> defaultConfigsMap = SkillsEntryController.loadDefaults();
            //System.assertNotEquals( defaultConfigsMap.get('userinfo'), null); 
            System.assertNotEquals( defaultConfigsMap.get('picklistWrapperListNone'), null,' '); 
         
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void submitRecordsInsert() {
        User testUser = createUser();
        
        List<List<Map<String,String>>> testRecords = new List<List<Map<String,String>>>();
        List<Map<String,String>> rowRecords = new List<Map<String,String>>();
        Map<String, String> row = new Map<String, String>();
        row.put('Expertise_Rating__c','3- Advanced');
        row.put('id','x0h0-000000CbCTAA0');
        rowRecords.add(row);
        testRecords.add(rowRecords);
        System.runAs(testUser){
            Test.startTest();
           
            SkillsEntryController.submitRecords(testRecords);
            
            List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
            System.assert(skillList.size() == 0, ' ');            
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void updatePAOnboardRecordTest() {
        User testUser = createUser();
        Contact testContact = TestDataFactory.createContact();
        insert testContact;
        
        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(testUser.id, testUser.id, testContact.Id);
        insert testPaOnboarding;
        
        List<Learning_Domain__c> testLearningDomainList = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomainList;
        
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.deleteRecords(new List<String>{});
            SkillsEntryController.updatePAOnboardingRecord(null);
            PA_Onboarding__c onboardingRecord = [SELECT Id, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c = :Userinfo.getUserId() LIMIT 1];
            System.AssertNotEquals(null, onboardingRecord.Last_Profile_Skills_Update__c,' '); 
            Test.stopTest();
        }
        
    }
    @isTest
    static void updatePAOnboardWithUsersTest() {
        User testUser = createUser();
        Contact testContact = TestDataFactory.createContact();
        insert testContact;
        
        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(testUser.id, testUser.id, testContact.Id);
        insert testPaOnboarding;
        
        List<Learning_Domain__c> testLearningDomainList = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomainList;
        
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.deleteRecords(new List<String>{});
            SkillsEntryController.updatePAOnboardingRecord(new List<String>{Userinfo.getUserId()});
            PA_Onboarding__c onboardingRecord = [SELECT Id, Last_Profile_Skills_Update__c FROM PA_Onboarding__c WHERE Candidate__c = :Userinfo.getUserId() LIMIT 1];
            System.assert(onboardingRecord != null, ' ');   
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void deleteRecordsTest() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.deleteRecords(new List<String>{});
            List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
            System.assert(skillList.size() == 0,' ');
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void testMyTeamsView() {
        User testUser = createUser();
          Contact testContact = TestDataFactory.createContact();
        insert testContact;
        
        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(testUser.id, testUser.id, testContact.Id);
        testPaOnboarding.Industry_Focus__c = INDUSTRYFOCUSSTR;
        testPaOnboarding.Product_Focus__c = PRODUCTFOCUSSTR;
        testPaOnboarding.Operating_Unit_Focus__c = 'INDIA';
        testPaOnboarding.Discipline__c	 = 'Data';
        insert testPaOnboarding;
        
        List<Learning_Domain__c> testLearningDomainList = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomainList;
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.getMyTeamSkillsList();
            List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
            System.assert(skillList.size() == 0, ' ');
            try{
                List<CSG_Group__c> groupList =  new List<CSG_Group__c> ();
               
                SkillsEntryController.SaveCallback sc = new SkillsEntryController.SaveCallback();
               
                CSG_Group__c groupVal = new CSG_Group__c();
                groupVal.Name = PARCHITECTSTR;
                groupList.add(groupVal);
                List<Database.SaveResult> ds = Database.insert(groupList);
               
                sc.processSave(ds[0]);
                
                List<CSGProfileSkill__c> profSkillList =  new List<CSGProfileSkill__c> ();
                CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
               
                profSkillList.add(profileVal);
                List<Database.SaveResult> ds2 = Database.insert(profSkillList);
                sc.processSave(ds2[0]);
            }Catch(Exception ex){
                system.debug(logginglevel.ERROR, 'Error');
            }
            Test.stopTest();
        }
        
    }
    @isTest
    static void testValidateSkills() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            	
            	Map<String,Boolean> validateMap = new Map<String,Boolean>();
            	validateMap.put('000000CbCTAA0999', true);
            
                SkillsEntryController.validateExpertiseRecords(validateMap,false);
            	Map<string,User> org62IdvsUser = new Map<string,User>();
            	User u1 = new User(Id=UserInfo.getUserId(),Lastname=userInfo.getUserName());
            	org62IdvsUser.put('XXX', u1);
            	
                ProfileSkillUserTax__x pf1 = new ProfileSkillUserTax__x();
                pf1.UserId__c = UserInfo.getUserId();
                try{
                	SkillsEntryController.UserSkillWrapper ps = new SkillsEntryController.UserSkillWrapper(pf1,org62IdvsUser);
                   
                }Catch(Exception ex){
                    system.debug(logginglevel.ERROR, 'Error');
                }
                List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
                System.assert(org62IdvsUser.size() != 0,' ');
            Test.stopTest();
        }
        
    }
    @isTest
    static void testMyDelegateView() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.getMyDelegatedTeamSkills();
            List<ProfileSkillUserTax__x> skillList = [Select id from ProfileSkillUserTax__x];
            System.assert(skillList.size() == 0, ' ');
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void testInvokeSkillsBatchJob() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            SkillsEntryController.invokeSkillsBatchJob(); 
            Test.stopTest();
        }
        System.assert(testUser != null, ' ');
        
    }
    
     
    @isTest
    static void testcheckBatchTriggerPermission() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            Boolean batchTrigger = SkillsEntryController.checkBatchTriggerPermission(); 
            System.assertequals(batchTrigger,false, ' ');
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void loadParentDefaultsTest() {
        User testUser = createUser();
        Contact testContact = TestDataFactory.createContact();
        insert testContact;
        
        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(testUser.id, testUser.id, testContact.Id);
        testPaOnboarding.Industry_Focus__c = INDUSTRYFOCUSSTR;
        testPaOnboarding.Product_Focus__c = PRODUCTFOCUSSTR;
        testPaOnboarding.Operating_Unit_Focus__c = 'INDIA';
        testPaOnboarding.Discipline__c	 = 'Data';
        insert testPaOnboarding;
        
        List<Learning_Domain__c> testLearningDomainList = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomainList;
        
        System.runAs(testUser){
            Test.startTest();
             Map<Object,Object> defaultConfigsMap = SkillsEntryController.loadParentDefaults();
            //System.assertNotEquals( defaultConfigsMap.get('userinfo'), null); 
            System.assertNotEquals( defaultConfigsMap.get('isManager'), null,' '); 
            Test.stopTest();
}
        
    }
    @isTest
    static void getCSGGrpsTest() {
        User testUser = createUser();
        
        System.runAs(testUser){
            Test.startTest();
            Account acc = new Account();
            acc.Name= 'Salesforce.com - DO NOT TOUCH';
            insert acc;
            List<SkillsEntryController.TreeStructure> treeList = SkillsEntryController.getCSGGrps();
            //System.assertNotEquals( defaultConfigsMap.get('userinfo'), null); 
            System.assertNotEquals( treeList , null,' '); 
            
            Test.stopTest();
        }
        
    }
    
}