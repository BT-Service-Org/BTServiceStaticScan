/**
Class Name : PlaybookLookupControllerTest
@description    : PlaybookLookupControllerTest Test class to take the code coverage and validate unit tests.
Created Date	: 14th Sept, 2023
*/

@isTest
public class PlaybookLookupControllerTest {
    @TestSetup
    static void setUpData() {
        
        ProjectMethodTestDataFactory.createBaseData();
    }

    @IsTest
    static void testFetchLookupData() {

        PlaybookLookupController playbook = new PlaybookLookupController();

        String searchKey = 'Test'; 
        String sObjectApiName = 'Method__c'; 
        String recordType = ''; 
        boolean statusCondition = True;
        
        List<sObject> result = new List<sObject>();

        result = PlaybookLookupController.fetchLookupData(searchKey, sObjectApiName, recordType, statusCondition);

        Assert.areEqual(2, result.size(), 'result is not as expected');
        Assert.areNotEqual(0, result.size(), 'result is not as expected');
        
        
        recordType = 'Published';
        result = PlaybookLookupController.fetchLookupData(searchKey, sObjectApiName, recordType, statusCondition);
        Assert.areNotEqual(0, result.size(), 'result is not as expected');
    }
    
    @IsTest
    static void testFetchDefaultRecord() {
         
        String sObjectApiName = 'Method__c'; 
        String recordId = [SELECT Id FROM Method__c LIMIT 1].Id; 
        
        sObject result;

        result = PlaybookLookupController.fetchDefaultRecord(recordId, sObjectApiName);
        Assert.areEqual(recordId, result.Id, 'result is not as expected');    
        
        result = PlaybookLookupController.fetchDefaultRecord('', sObjectApiName);
        Assert.areEqual(null, result, 'result is not as expected');    

    }
    
}