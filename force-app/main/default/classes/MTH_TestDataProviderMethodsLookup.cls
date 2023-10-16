@isTest
public with sharing class MTH_TestDataProviderMethodsLookup {

    @isTest
    private static void getMethods_givenMethodNameAndProjectId_shouldReturnAsSlackOption() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Method__c mockMethod = MethodDataAccessorTest.buildMethod('Must Use');
        upsert mockMethod;

        Test.startTest();
        Slack.OptionDataResponse optionDataResponse = MTH_DataProviderMethodsLookup.getMethodsByName(project.Id, 'Assess Business Capabilities');
        Test.stopTest();

        List<Slack.Option> options = optionDataResponse.getOptions();
        System.assertEquals('Assess Business Capabilities', options[0].getText(), 'should return option text');
    }
}