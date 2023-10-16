/**
 * @description : LwcMultiLookupControllerTest
 */
@isTest
public class LwcMultiLookupControllerTest {
	
	Static string standardUser = 'Standard User';
     /**
     * @description :loadData
     */
	@testsetup
    public static void loadData(){
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
        Account acc     = new Account();
        acc.Name    = 'Salesforce.com - DO NOT TOUCH';
       	insert acc;
    }
     /**
     * @description :testUserRecordsPostive
     */
    @isTest
    static void testUserRecordsPostive() {
        Test.startTest();
        TestDataFactory.createUser(StandardUser,'Testing');
        list<lwcMultiLookupController.SObjectResult> results = lwcMultiLookupController.getResults('User','Name','Testing',new List<String>(),null);
        
        Test.stopTest();
        System.assert(results.size() > 0,'');
    }
        /**
         * @description :testUserRecordsNegative
         */
        @isTest
        static void testUserRecordsNegative() {
        Test.startTest();
        User u = TestDataFactory.createUser(StandardUser,'Benjamin');
        list<lwcMultiLookupController.SObjectResult> results = lwcMultiLookupController.getResults('User','Name','Testing',new List<String>(),null);
        System.assert(results.size() == 0,'');
        results = lwcMultiLookupController.getResults('User','Name','Benjamin',new List<String>(),new List<string> {u.id});
		System.assert(results.size() != 0,'');
        Test.stopTest();
        
	}
}