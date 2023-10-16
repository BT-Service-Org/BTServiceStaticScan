@isTest
public with sharing class FeatureToggleRestServiceTest {
	public FeatureToggleRestServiceTest() {

	}

	@isTest
	public static void getFlagStateTest(){
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle('Test_FT_1', true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle('Test_CFT_1', true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		FeatureToggleRestService.RequestData rData = new FeatureToggleRestService.RequestData();
		rData.childToggleLabel = null;
		rData.parentToggleLabel= 'Test_FT_1';
		Test.startTest();
		String result = FeatureToggleRestService.getFlagState(rData);
		Test.stopTest();
		System.assert (result == 'true', 'getFlagStateTest has not expexted behavior');
	}
}