@isTest(seealldata=false)
private class tf_TriggerHandlerRegistryUtilTest {
    @isTest
    static void getEventHandlerMapTest() {
        Map<String, List<String>> eventHandlerMap;
        Boolean exceptionThrown = false;
        /*
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        tf_TriggerHandlerRegistryDAO mockDao = 
        (tf_TriggerHandlerRegistryDAO)mocks.mock(tf_TriggerHandlerRegistryDAO.class);
        
        
        Trigger_Handler_Registry__mdt[] mockEventHandlerMap = 
        new Trigger_Handler_Registry__mdt[]{
        new Trigger_Handler_Registry__mdt( 
        SObject_Name__c = 'Account',
        Trigger_Event__c = 'BEFORE_INSERT',
        Execution_Order_of_the_Handler__c = 1.0,
        Trigger_Handler_Name__c = 'AccountTriggerHandlerTest'
        )
        };
        
        mocks.startStubbing();
        mocks.when(mockDao.getTriggerHandlerRegistryEntries('Account'))
        .thenReturn(mockEventHandlerMap);
        mocks.stopStubbing();
        
        //inject the mock dao class for testing
        tf_TriggerHandlerRegistryUtil.setMockDao(mockDao);
        */
        
        try {
            eventHandlerMap = tf_TriggerHandlerRegistryUtil.getEventHandlerMap('CSGProfileSkill__c');
            List<CSGProfileSkill__c> profSkillList =  new List<CSGProfileSkill__c> ();
            CSGProfileSkill__c profileVal = new CSGProfileSkill__c();
            profileVal.Category__c = 'Test cat';
            profileVal.Description__c = 'Test desc';
            profileVal.CSG_Community__c = 'Test community';
            profileVal.External_Id__c = 'a4V3C00000014hWUAQ';
            profSkillList.add(profileVal);
            
            //insert profSkillList; 
        } catch (tf_TriggerException ex) {
            exceptionThrown = true;
        }
        
        System.assert(!exceptionThrown, 
                      'Exception should not be thrown when event handler exists for registry name');
        /*
        System.assert(eventHandlerMap.size() == 1, 
                      'There should one event handler for one custom metadata type record for Account');
        
        System.assert(eventHandlerMap.containsKey(TriggerOperation.BEFORE_INSERT.name()), 
                      'Based on the custom metadata type record for Account, the "BEFORE_INSERT" event should be contained in the map');
        System.assert(eventHandlerMap.get(TriggerOperation.BEFORE_INSERT.name()).size() == 1, 
                      'There shoud be one handler for "BEFORE_INSERT" event for one custom metadata type record for Account');
        */
	}
    
    @isTest
    static void getEventHandlerMapExceptionSObjectNameEmptyStringTest() {
        Boolean exceptionThrown = false;
        String expectedExceptionMessage = 'The SObject Name can not be Blank!';
        String exceptionMessage;
        try {
            tf_TriggerHandlerRegistryUtil.getEventHandlerMap('');
        } catch (tf_TriggerException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        
        System.assert(exceptionThrown, 'When SObject name is empty string, exception should be thrown');
        System.assertEquals(expectedExceptionMessage, exceptionMessage, 'When exception is thrown for a blank SObject name, the exception message should "' + expectedExceptionMessage + '"');
    }
    
    @isTest
    static void getEventHandlerMapExceptionSObjectNameNullTest() {
        Boolean exceptionThrown = false;
        String expectedExceptionMessage = 'The SObject Name can not be Blank!';
        String exceptionMessage;
        try {
            tf_TriggerHandlerRegistryUtil.getEventHandlerMap(null);
        } catch (tf_TriggerException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        
        System.assert(exceptionThrown, 'When SObject name is empty string, exception should be thrown');
        System.assertEquals(expectedExceptionMessage, exceptionMessage, 'When exception is thrown for a blank SObject name, the exception message should "' + expectedExceptionMessage + '"');
    }
    
    @isTest
    static void getHandlerInstance_InvalidClass_ThrowException(){
        String className = 'NOT A CLASS NAME';
        Boolean exceptionThrown = false;
        try{
            tf_TriggerHandlerRegistryUtil.getHandlerInstance(className);
        } catch(Exception ex){
            exceptionThrown = true;
        }
        System.assert(
            exceptionThrown,
            'getHandlerInstance should throw an error if the class name parameter is not an actual class'
        );
    }
    
    @isTest
    static void getHandlerInstance_InvalidHandler_ThrowException(){
        String className = 'CSGProfileSkillTriggerHandlerTest';
        Boolean exceptionThrown = false;
        try{
            tf_TriggerHandlerRegistryUtil.getHandlerInstance(className);
        } catch(Exception ex){
            exceptionThrown = true;
        }
        System.assert(
            exceptionThrown,
            'getHandlerInstance should throw an exception if the class name parameter can not be an instance of tf_triggerHandler'
        );
    }
}