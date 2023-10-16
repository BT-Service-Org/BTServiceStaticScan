@isTest
private class SpotBonusTest 
{
	@isTest 
	static void TestAfterInsertTrigger() 
	{
		Contact c = new Contact(FirstName = 'Sam', LastName = 'Axe');
		insert c;

		PA_Customer_Survey__c cs1 = new PA_Customer_Survey__c(
			Account_Id__c = 'AccountId1',
			Contact__c = c.Id,
			Org62_Survey_Id__c = 'SurveyId1',
			Overall_Score__c = 9,
			Project_id__c = 'ProjectId1',
			Survey_Completed_Date__c = System.today()
		);
		insert cs1;

		PA_Customer_Survey__c cs2 = new PA_Customer_Survey__c(
			Account_Id__c = 'AccountId2',
			Contact__c = c.Id,
			Org62_Survey_Id__c = 'SurveyId2',
			Overall_Score__c = 9.6,
			Project_id__c = 'ProjectId2',
			Survey_Completed_Date__c = System.today()
		);
		insert cs2;

		Spot_Bonus__c sp1 = new Spot_Bonus__c(
			Account_Id__c = 'AccountId1',
			Contact__c = c.Id,
			Fiscal_Year__c = 2015
		);
		insert sp1;

		Integer csCount1 = [select count() from PA_Customer_Survey__c where Spot_Bonus__c =: sp1.Id];
		System.assertEquals(2, csCount1, 'Spot Bonus not assigned correctly');

		PA_Customer_Survey__c cs3 = new PA_Customer_Survey__c(
			Account_Id__c = 'AccountId3',
			Contact__c = c.Id,
			Org62_Survey_Id__c = 'SurveyId3',
			Overall_Score__c = 9.4,
			Project_id__c = 'ProjectId3',
			Survey_Completed_Date__c = System.today()
		);
		insert cs3;

		Spot_Bonus__c sp2 = new Spot_Bonus__c(
			Account_Id__c = 'AccountId3',
			Contact__c = c.Id,
			Fiscal_Year__c = 2015
		);
		insert sp2;

		Integer csCount2 = [select count() from PA_Customer_Survey__c where Spot_Bonus__c =: sp2.Id];
		System.assertEquals(1, csCount2, 'Spot Bonus not assigned correctly');
	}
}