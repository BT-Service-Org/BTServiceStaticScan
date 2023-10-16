@isTest
public with sharing class FeatureToggleConfigurationControllerTest {

	@isTest
	public static void defaultConstructorTest(){

		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle('Test_FT_1', true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle('Test_CFT_1', true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);

		FeatureToggleService.setMockQueryService(mockService);

		FeatureToggleConfigurationController c = new FeatureToggleConfigurationController();

		System.assert (c.childFeatureToggleFields.size()> 0 && c.featureToggleFields.size() > 0 && c.featureToggles.size() > 0,
		               'defaultConstructorTest has not expected behavior');
	}

	@isTest
	public static void cleanupCache(){
		FeatureToggleConfigurationController c = new FeatureToggleConfigurationController();
		if (!FeatureToggleService.isCacheEnabled) {
			try {
				c.cleanupTheCache();
			} catch (Exception e) {
				System.assert(e.getMessage() != null);
			}
		}
	}
}