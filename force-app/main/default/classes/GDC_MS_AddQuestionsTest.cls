@isTest
public with sharing class GDC_MS_AddQuestionsTest {
    
    @testSetup static void setup() {
        gdc_ms_Question__c objQues = new gdc_ms_Question__c();
        objQues.gdc_ms_Question__c = 'Question1';
        objQues.gdc_ms_Required__c = true;
        objQues.gdc_ms_Type__c = 'Text';
        objQues.gdc_ms_Order__c = 1;
        objQues.gdc_ms_Is_Active__c = true;
        objQues.gdc_ms_Category__c = 'Intake';
        insert objQues;
    }
	
    static testMethod void getPicklistValuesTest() {
        test.startTest();
        GDC_MS_AddQuestions.Picklists objPicklists = GDC_MS_AddQuestions.getPicklistValues();
        System.assert(!objPicklists.categoryOptions.isEmpty());
        System.assert(!objPicklists.typeOptions.isEmpty());
        test.stopTest();
    }
    
    static testMethod void getObjectNameTest() {
        test.startTest();
        String strObjectName = GDC_MS_AddQuestions.getObjectName('Intake');
        System.assert(strObjectName=='gdc_ms_Work_Intake_Form');
        test.stopTest();
    }
    
    static testMethod void getQuestionsTest() {
        test.startTest();
        List<gdc_ms_Question__c> lstQuestions = GDC_MS_AddQuestions.getQuestions('Intake');
        System.assert(lstQuestions.size() == 1);
        test.stopTest();
    }
}