@isTest
public with sharing class GDC_MS_ScoreCalculationTest {
    
    Public static gdc_ms_Question__c createQuestion(String strQues,String strType, String strCategory){
        gdc_ms_Question__c objQues = new gdc_ms_Question__c();
        objQues.gdc_ms_Question__c = strQues;
        objQues.gdc_ms_Type__c = strType;
        objQues.gdc_ms_Is_Active__c = true;
        objQues.gdc_ms_Category__c = strCategory;
        return objQues;
    }
    Public static gdc_ms_Question_Answer__c createQuestionAnswer(Id idQues,String strAnswer, Id WID){
        gdc_ms_Question_Answer__c objQuesAns = new gdc_ms_Question_Answer__c();
        objQuesAns.gdc_ms_Question__c = idQues;
        objQuesAns.gdc_ms_Answer__c = strAnswer;
        objQuesAns.gdc_ms_Work_Intake_Form__c = WID;
        return objQuesAns;
    }
	@testSetup static void setup() {
        List<gdc_ms_Question__c> lstQuestions = new List<gdc_ms_Question__c>();
        lstQuestions.add(createQuestion('Question1','Text','Intake'));
        lstQuestions.add(createQuestion('Question2','Checkbox','Intake'));
        lstQuestions.add(createQuestion('Question3','Text','Intake'));
        insert lstQuestions;
        
        gdc_ms_Work_Intake_Form__c  objWIF = new gdc_ms_Work_Intake_Form__c ();
        objWIF.gdc_ms_External_Id__c = 'Test';
        objWIF.Name = 'Test Engagement';
        insert objWIF;
        
        List<gdc_ms_Question_Answer__c> lstQuestionAns = new List<gdc_ms_Question_Answer__c>();
        lstQuestionAns.add(createQuestionAnswer(lstQuestions[0].Id,'Test',objWIF.Id));
        lstQuestionAns.add(createQuestionAnswer(lstQuestions[1].Id,'false',objWIF.Id));
        lstQuestionAns.add(createQuestionAnswer(lstQuestions[2].Id,'',objWIF.Id));
        insert lstQuestionAns;
    }
	
    static testMethod void getCountTest() {
        gdc_ms_Work_Intake_Form__c  objWIF = [SELECT Id FROM gdc_ms_Work_Intake_Form__c LIMIT 1];
        test.startTest();
        GDC_MS_ScoreCalculation.ScoreWrapper objScoreWrapper = GDC_MS_ScoreCalculation.getCount(objWIF.Id);
        System.assert(objScoreWrapper.intPercentage == 33);
        test.stopTest();
    }
}