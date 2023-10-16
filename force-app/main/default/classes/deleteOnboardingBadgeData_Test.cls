@isTest(seeAllData = false)
public class deleteOnboardingBadgeData_Test {

    static testmethod void test() {
		// Create test data to be deleted by the batch job.
	    List<Badge__c> lstBadges = new List<Badge__c>();
        List<PA_Onboarding__c> lstOnboardings = new List<PA_Onboarding__c>();
		List<Onboarding_Badge_Data__c> lstOnboardingBadges = new List<Onboarding_Badge_Data__c>();
        
        for (Integer i=0; i<20; i++) {
            Badge__c aBadge = new Badge__c(Name = 'Badge '+i);
            lstBadges.add(aBadge);
        }
        insert lstBadges;
        
        Contact aContact = new Contact(LastName = 'LastName', FirstName = 'FirstName');
        insert aContact;
        Id PARecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;
        PA_Onboarding_Property__c prop = PA_Onboarding_Property__c.getValues('Template PA Onboarding Id');
            
        for (Integer i=0; i<1; i++) {  
            PA_Onboarding__c anOnboarding = new PA_Onboarding__c();
            anOnboarding.RecordTypeId = PARecordTypeId;
            anOnboarding.Name = 'Person '+i;
            anOnboarding.Program_Start_Date__c = System.today();
            anOnboarding.Contact__c = aContact.Id;
            anOnboarding.Candidate_Email__c = 'someone'+i+'@test.com';
            lstOnboardings.add(anOnboarding);            
        }
        insert lstOnboardings;    
        
        for (Integer i=0; i<200; i++) {            
			Onboarding_Badge_Data__c onBadge = new Onboarding_Badge_Data__c();
            onBadge.Name__c = 'Onboarding_Badge ' + i;
			lstOnboardingBadges.add(onBadge);          
		}
		insert lstOnboardingBadges;

		Test.startTest();
		deleteOnboardingBadgeData batchClass = new deleteOnboardingBadgeData();
		Database.executeBatch(batchClass);
		Test.stopTest();

		// Verify all are deleted
		Integer numOnboardingBadges = [SELECT count() FROM Onboarding_Badge_Data__c];
		System.assert(numOnboardingBadges == 0);
	}
    
}