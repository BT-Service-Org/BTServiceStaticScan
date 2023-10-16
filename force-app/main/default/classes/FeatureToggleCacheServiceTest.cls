@isTest
public with sharing class FeatureToggleCacheServiceTest {

	@isTest
	public static void toggleEnabledTest(){
		Test.startTest();
		Boolean cacheEnabled1 = FeatureToggleCacheService.toggleEnabled();
		Boolean cacheEnabled2 = FeatureToggleCacheService.toggleEnabled();
		Test.stopTest();
		System.assert (cacheEnabled1 != cacheEnabled2, 'toggleEnabledTest has not expexted behavior');

    }
    @isTest
	public static void getFromCache(){
		if (!FeatureToggleService.isCacheEnabled) {
            System.assert(FeatureToggleCacheService.getFromCache() == null);
        } else {
            System.assert(FeatureToggleCacheService.getFromCache().size() > 0);
        }
	}

}