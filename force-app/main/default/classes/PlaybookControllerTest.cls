/**
Class Name : PlaybookControllerTest
@description    : PlaybookControllerTest Test class to take the code coverage and validate unit tests.
Created Date	: 8th Sept, 2023
*/

@isTest
public class PlaybookControllerTest {
    @TestSetup
    static void setUpData() {
        
        ProjectMethodTestDataFactory.createBaseData();
    }

    @IsTest
    static void testSavePlaybookDetails() {
        
        String playbookId = [SELECT Id FROM Playbook__c].Id;
        String actualJsonResult = PlaybookController.getPlaybookDetails(playbookId);
        Assert.isNotNull(actualJsonResult, 'Wrapper should not be null');

        String result = PlaybookController.savePlaybookDetails(actualJsonResult);
        
        Assert.areNotEqual(null, result, ' should return a result');

        Playbook__c playbook = [SELECT Id, Name, Status__c FROM Playbook__c WHERE Id = :result];
        Assert.areNotEqual(null, playbook.Status__c, ' It should return status');
        
        
    }
    

    @IsTest
    static void testCreateDraftPlayBook() {
        
        String playbookId = [SELECT Id FROM Playbook__c].Id;
        String actualJsonResult = PlaybookController.getPlaybookDetails(playbookId);        

        String result = PlaybookController.createDraftPlayBook(actualJsonResult);
        
        
        Playbook__c insertedPlaybook = [SELECT Id, Status__c FROM Playbook__c WHERE Id = :result];

        Assert.areNotEqual(null, insertedPlaybook, 'Error');
        Assert.areEqual('Draft', insertedPlaybook.Status__c, 'Error');

    }


    @isTest
    static void testCreateOutcomeRecord(){
        
        String testName = 'Test Outcome';
        String testDescription = 'This is a test outcome';
        String testTitle = 'Test Title';

        PlaybookController.createOutcomeRecord(testName, testDescription, testTitle);
        
        Outcome__c insertedRecord = [SELECT Id, Name, Description__c, Title__c FROM Outcome__c WHERE Title__c = 'Test Title' LIMIT 1];
        System.assertEquals(testTitle, insertedRecord.Title__c, 'Error');
        System.assertNotEquals(null, insertedRecord.Id, 'Error');
    }



    @isTest
    static void testGetMethodOutcomes(){
        
        Id methodRecordTypeId = Schema.SObjectType.Outcome__c.getRecordTypeInfosByName().get('Method').getRecordTypeId();

        Method__c method = new Method__c();
        method.Name = 'Test Method';
        insert method;

        Outcome__c outcome = new Outcome__c();
        outcome.Name = 'Test Outcome';
        outcome.RecordTypeId = methodRecordTypeId;
        insert outcome;

        Method_Outcome__c methodOutcome = new Method_Outcome__c();
        methodOutcome.Method__c = method.Id;
        methodOutcome.Outcome__c = outcome.Id;
        insert methodOutcome;

        sObject result = PlaybookController.getMethodOutcomes(method.Id);

        
        Assert.areNotEqual(null, result, 'Method should return a valid result');
        Method__c returnedMethod = (Method__c)result;
        Assert.areEqual(method.Id, returnedMethod.Id, 'Returned Method Id should match the input');
        Assert.areEqual('Test Method', returnedMethod.Name, 'Returned Method Name should match the input');

        // Negative Scenario
        sObject negativeResult = PlaybookController.getMethodOutcomes('');
        Assert.areEqual(null, negativeResult, 'Method should return null for an invalid record Id');
    }


}