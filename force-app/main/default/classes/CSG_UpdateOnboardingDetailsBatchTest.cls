/*
Apex class Name : CSG_UpdateOnboardingDetailsBatchTest
Description		: Test class for CSG_UpdateOnboardingDetailsBatch
Created Date	: Aug 7, 2022  
*/
@isTest(SeeAllData=false)
public class CSG_UpdateOnboardingDetailsBatchTest { 

    public static final String TESTCAT ='Test cat';
    public static final String TESTDESC ='Test desc';
    public static final String TESTCOMMUNITY ='Test community';
    public static String userIdValue ='005300000022YWmAAM';
    
     /**
     @description : Test data setup for CSG Group, CSG ProfileSkill and GroupSkill    
     @param  - none 
    */
    @testsetup
    public static void loadData(){
	    
	 Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
         
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
        
        List<ProfileSkillTax__x> profSkillTaxList =  new List<ProfileSkillTax__x> ();
        ProfileSkillTax__x profileTaxVal = new ProfileSkillTax__x();
        profileTaxVal.Category_c__c = TESTCAT;
        profileTaxVal.Description__c = TESTDESC;
        profileTaxVal.Name__c = TESTCOMMUNITY;
        profileTaxVal.ExternalId = 'a4V3C00000014hWUAR';
        profileTaxVal.Sub_Category_c__c ='';
        profileTaxVal.Last_Modified_Date__c= datetime.now();
        profileTaxVal.ExternalId='';
        profileTaxVal.ProfileSkillTaxId__c='';
        profSkillTaxList.add(profileTaxVal);
        
        List<ProfileSkillUserTax__x> profSkillTaxUserList =  new List<ProfileSkillUserTax__x> ();
        ProfileSkillUserTax__x profileTaxUserVal = new ProfileSkillUserTax__x();
        profileTaxUserVal.Last_Modified_Date__c = datetime.now();
        profileTaxUserVal.UserId__c = userinfo.getuserid();
      
        profileTaxUserVal.ProfileSkillId__c = '';
        profSkillTaxUserList.add(profileTaxUserVal);
        
    }
    
    
    /**
     @description : Test data setup for User
     @return : User
     @param  - none 
    */
    public static User createUser() {
        String hostname = '@sfservices.com.skdev'; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
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
            UserName= uid + hostname,
            Org62Id__c = userIdValue
            
        );
        insert testUser;
        return testUser;
    }
    
    /**
     @description : Test the batch class to update Skills Taxonomy
     @param  - none 
    */
    @isTest
    static  void submitRecordsUpdate() {
        
            User testUser = createUser();
        
            System.runAs(testUser){
                
            Contact testContact = TestDataFactory.createContact();
        	insert testContact;
                
            user candidateuser = [ Select id from user where Org62Id__c =: userIdValue];
        
            PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(candidateuser.id, testUser.id, testContact.Id);
            //Disable trigger, to only create Onboarding test data
        	LPOnboardingPrepareTriggerHandler.disable = true;
            insert testPaOnboarding;

            Test.startTest();
                        
            List<ProfileSkillTax__x> profSkillTaxList =  new List<ProfileSkillTax__x> ();
			//This is an existing ProfileSkillTax__xl record with matching external id
            ProfileSkillTax__x profileTaxVal = new ProfileSkillTax__x();
            profileTaxVal.Category_c__c = TESTCAT;
            profileTaxVal.Description__c = TESTDESC;
            profileTaxVal.Name__c = TESTCOMMUNITY;
            profileTaxVal.Sub_Category_c__c ='';
            profileTaxVal.Last_Modified_Date__c= datetime.now();
            profileTaxVal.ExternalId='a4V3C00000014hWUAR';
            profileTaxVal.ProfileSkillTaxId__c='';
            profSkillTaxList.add(profileTaxVal);
            
                
                
            List<ProfileSkillUserTax__x> profSkillTaxUserList =  new List<ProfileSkillUserTax__x> ();
            ProfileSkillUserTax__x profileTaxUserVal = new ProfileSkillUserTax__x();
            profileTaxUserVal.Last_Modified_Date__c = datetime.now()-5;
            profileTaxUserVal.UserId__c = userIdValue ;
            profileTaxUserVal.ProfileSkillId__c = '';
            profSkillTaxUserList.add(profileTaxUserVal);

            profileTaxUserVal = new ProfileSkillUserTax__x();
            profileTaxUserVal.Last_Modified_Date__c = datetime.now();
            profileTaxUserVal.UserId__c = userIdValue;
            profileTaxUserVal.ProfileSkillId__c = '';
            profSkillTaxUserList.add(profileTaxUserVal);
           
                 
            
 			CSG_UpdateOnboardingDetailsBatch invokeBatch = new CSG_UpdateOnboardingDetailsBatch(); 
                 
            invokeBatch.start(null);
            invokeBatch.execute(null, profSkillTaxUserList);
            invokeBatch.finish(null);
                
            Map<ID,Datetime>  userDateMap = new  Map<ID,Datetime>();
            string isSuccess = invokeBatch.performExecution(profSkillTaxUserList,userDateMap);
            
            System.assertEquals(isSuccess,'Success','Fail');  
             
            CSG_UpdateOnboardingBatchScheduler sh1 = new CSG_UpdateOnboardingBatchScheduler(); 
			String sch = '0 0 23 * * ?'; 
            system.schedule('Test update onboarding', sch, sh1);    
                   
            }
            Test.stopTest();
        }
    }