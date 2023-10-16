@isTest
public with sharing class FeatureToggleServiceTest {

	private final static String EXISTING_PFT = 'Test_FT_1';
	private final static String EXISTING_CFT = 'Test_CFT_1';
	private final static String NON_EXISTING_LABEL = 'nonExistsLabel';
	public FeatureToggleServiceTest(){
	}


	private static void setCache(){
		FeatureToggleService.isCacheEnabled = true;
		FeatureToggleQueryService.FeatureCondition basicParentCondition = new FeatureToggleQueryService.FeatureCondition();
		basicParentCondition.setQuery('DeveloperName = \''+EXISTING_PFT+'\'');
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleTestUtilities.MockFeatureToggleQueryService mockService = new FeatureToggleTestUtilities.MockFeatureToggleQueryService(parentRec, childRec);
		FeatureToggleService.cachedToggles = mockService.createFeatureToggleMetadata(parentRec, childRec);
	}


	private static void disableCache(){
		FeatureToggleService.isCacheEnabled = false;
	}


	@isTest
	public static void getFeatureStateTest1(){
		//Testing a case without cache
		disableCache();
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, null);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(EXISTING_PFT);
		Test.stopTest();
		System.assert (resultState, 'getFeatureStateTest1 has not expexted behavior');
	}


	@isTest
	public static void getFeatureStateTest2(){
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(NON_EXISTING_LABEL);
		Test.stopTest();
		System.assert (!resultState, 'getFeatureStateTest2 has not expexted behavior');
	}

 
	@isTest
	public static void getFeatureStateTest3(){
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, null);
		FeatureToggleService.setMockQueryService(mockService);
		//Testing a case with cache
		setCache();
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(EXISTING_PFT);
		Test.stopTest();
		System.assert (resultState, 'getFeatureStateTest3 has not expexted behavior');
	}


	@isTest
	public static void getParameterizedFeatureStateTest1(){
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, null);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		Boolean resultState = FeatureToggleService.getParameterizedFeatureState(EXISTING_PFT, null);
		Test.stopTest();
		System.assert (resultState, 'getParameterizedFeatureStateTest1 has not expexted behavior');
	}

 
	@isTest
	public static void getParameterizedFeatureStateTest2(){
		Test.startTest();
		Boolean resultState = FeatureToggleService.getParameterizedFeatureState(NON_EXISTING_LABEL, null);
		Test.stopTest();
		System.assert (!resultState, 'getParameterizedFeatureStateTest2 has not expexted behavior');
	}


	@isTest
	public static void getParameterizedFeatureStateWithChildTest1(){
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		FeatureToggleService.includeMetadataFields = true;
		Boolean resultState = FeatureToggleService.getParameterizedFeatureState(EXISTING_PFT, null, EXISTING_CFT, null);
		Test.stopTest();
		System.assert (resultState, 'getParameterizedFeatureStateWithChildTest1 has not expexted behavior');
	}

	@isTest
	public static void getParameterizedFeatureStateWithChildTest2(){
		Test.startTest();
		Boolean resultState = FeatureToggleService.getParameterizedFeatureState(NON_EXISTING_LABEL, null, NON_EXISTING_LABEL, null);
		Test.stopTest();
		System.assert (!resultState, 'getParameterizedFeatureStateWithChildTest2 has not expexted behavior');
	}

	@isTest
	public static void getParameterizedFeatureStateWithChildTest3(){
		Test.startTest();
		Boolean resultState = FeatureToggleService.getParameterizedFeatureState(EXISTING_PFT, null, EXISTING_CFT, '{"Feature":"false"}');
		Test.stopTest();
		System.assert (!resultState, 'getParameterizedFeatureStateWithChildTest3 has not expexted behavior');
	}

	@isTest
	public static void getFeatureStateTest4(){
		disableCache();
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(EXISTING_PFT, EXISTING_CFT);
		Test.stopTest();
		System.assert (resultState, 'getFeatureStateTest4 has not expexted behavior');
	}


	@isTest
	public static void getFeatureStateTest5(){
		setCache();
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(EXISTING_PFT, EXISTING_CFT);
		Test.stopTest();
		System.assert (resultState, 'getFeatureStateTest5 has not expexted behavior');
	}


	@isTest
	public static void getFeatureStateTest6(){
		disableCache();
		Test.startTest();
		Boolean resultState = FeatureToggleService.getFeatureState(NON_EXISTING_LABEL, NON_EXISTING_LABEL);
		Test.stopTest();
		System.assert (!resultState, 'getFeatureStateTest6 has not expexted behavior');
	}


	@isTest
	public static void getFeatureTest1(){
		//Get Featue instance for not existing label
		Test.startTest();
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(NON_EXISTING_LABEL);
		Test.stopTest();
		Boolean result = !f.active && f.callbackClass == null && f.features.size() == 0;
		System.assert (result, 'getFeatureTest1 has not expexted behavior');
	}


	@isTest
	public static void getFeatureTest2(){
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		//Get Featue instance for existing label
		Test.startTest();
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(EXISTING_PFT);
		Test.stopTest();
		Boolean result = f.active && f.callbackClass != null && f.features.size() > 0;
		System.assert (result, 'getFeatureTest2 has not expexted behavior');
	}


	@isTest
	public static void getFeatureTest3(){
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		//Get Featue instance for existsting label with conditions
		FeatureToggleQueryService.FeatureCondition parentCondition = new FeatureToggleQueryService.FeatureCondition();
		parentCondition.setQuery('Callback__c = \'DummyFeature\'');
		FeatureToggleQueryService.FeatureCondition childCondition = new FeatureToggleQueryService.FeatureCondition();
		childCondition.setQuery('Callback__c = \'DummyFeature\'');
		Test.startTest();
		FeatureToggleService.includeMetadataFields = true;
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(EXISTING_PFT, parentCondition, EXISTING_CFT, childCondition);
		Test.stopTest();
		Boolean result = f.active && f.callbackClass != null && f.features.size() > 0;
		System.assert (result, 'getFeatureTest3 has not expexted behavior');
	}


	@isTest
    public static void getFeatureTest4(){
        Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		//Get Featue instance for existsting label with conditions
		FeatureToggleQueryService.FeatureCondition parentCondition = new FeatureToggleQueryService.FeatureCondition();
		parentCondition.setQuery('Callback__c = \'DummyFeature\'');
		FeatureToggleService.includeMetadataFields = true;

		Test.startTest();
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(EXISTING_PFT, parentCondition);
		Test.stopTest();

		Boolean result = f.active && f.callbackClass != null && f.features.size() > 0;
		System.assert (result, 'getFeatureTest4 has not expexted behavior');
	}


	@isTest
	public static void getFeatureTest5(){
		//Get Featue instance for existing label
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		Test.startTest();
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(EXISTING_PFT, EXISTING_CFT);
		Test.stopTest();
		Boolean result = f.active && f.callbackClass != null && f.features.size() > 0;
		System.assert (result, 'getFeatureTest5 has not expexted behavior');
	}


	@isTest
	public static void getFeatureTest6(){
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		Child_Feature_Toggle__mdt childRec = FeatureToggleTestUtilities.createChildFeatureToggle(EXISTING_CFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, childRec);
		FeatureToggleService.setMockQueryService(mockService);
		//Get Feature instance for existsting label with conditions
		FeatureToggleQueryService.FeatureCondition parentCondition = new FeatureToggleQueryService.FeatureCondition();
		parentCondition.setQuery('Callback__c = \'DummyFeature\'');
		Test.startTest();
		FeatureToggleService.Feature f = FeatureToggleService.getFeature(EXISTING_PFT, parentCondition, EXISTING_CFT);
		Test.stopTest();
		Boolean result = f.active && f.callbackClass != null && f.features.size() > 0;
		System.assert (result, 'getFeatureTest3 has not expexted behavior');
	}



	@isTest
	public static void getCustomFeatureTest(){


		try{
			Test.startTest();
			Featurable f = FeatureToggleService.getCustomFeature('DummyFeature');
			Test.stopTest();
			System.assert (f.getFeatureState(), 'getCustomFeatureTest has not expexted behavior');
		} catch (Exception e) {
			System.assert (false, 'There is an eror in getCustomFeatureTest method: ' + e);
		}
	}


	@isTest
	public static void featureConstructorTest(){
		Test.startTest();
		FeatureToggleService.Feature f = new FeatureToggleService.Feature(NON_EXISTING_LABEL, NON_EXISTING_LABEL);
		Test.stopTest();
		System.assert (!f.active && f.features.size() == 1, 'featureConstructorTest has not expexted behavior');

	}


	@isTest
	public static void featureDefaultConstructorTest(){
		Test.startTest();
		FeatureToggleService.Feature f = new FeatureToggleService.Feature();
		Test.stopTest();
		System.assert (!f.active, 'featureDefaultConstructorTest has not expexted behavior');

	}

	@isTest
	public static void featurConstructor2Test(){
		Feature_Toggle__mdt parentRec = FeatureToggleTestUtilities.createParentFeatureToggle(EXISTING_PFT, true, Date.today(), Date.today() + 30, 'DummyFeature');
		FeatureToggleQueryService mockService = FeatureToggleTestUtilities.createToggleQueryServiceMock(parentRec, null);
		FeatureToggleService.setMockQueryService(mockService);
		FeatureToggleQueryService.FeatureCondition parentCondition = new FeatureToggleQueryService.FeatureCondition();
		parentCondition.setQuery('DeveloperName = \'Test_FT_1_no_child\'');

		Test.startTest();

		Feature_Toggle__mdt ft = FeatureToggleService.getFeatureToggleRecords(parentCondition, null).get(0);

		FeatureToggleService.Feature f = new FeatureToggleService.Feature(ft, NON_EXISTING_LABEL);
		Test.stopTest();
		System.assert (f.active && f.features.size() == 1, 'featurConstructor2Test has not expexted behavior' + f);

	}

	@isTest
	public static void subFeatureDefaultConstructorTest(){
		Test.startTest();
		FeatureToggleService.Subfeature sf = new FeatureToggleService.Subfeature();
		Test.stopTest();
		System.assert (!sf.active, 'subFeatureDefaultConstructorTest has not expexted behavior');
	}

	@isTest
	public static void subFeatureConstructorTest(){
		Test.startTest();
		FeatureToggleService.Subfeature sf = new FeatureToggleService.Subfeature();
		Test.stopTest();
		System.assert (!sf.active, 'subFeatureDefaultConstructorTest has not expexted behavior');
	}
    
    
}