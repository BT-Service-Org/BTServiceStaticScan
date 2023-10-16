@isTest
public with sharing class GDC_MS_QuestionAnswerFormControllerTest {

   public static gdc_ms_Question__c createQuestion(String strQues,String strType,String strCategory){
        gdc_ms_Question__c objQues = new gdc_ms_Question__c();
        objQues.gdc_ms_Question__c = strQues;
        objQues.gdc_ms_Required__c = true;
        objQues.gdc_ms_Type__c = strType;
        objQues.gdc_ms_Is_Active__c = true;
        objQues.gdc_ms_Category__c = strCategory;
        return objQues;
   }

   public static gdc_ms_Question_Answer__c createQuestionAnswer(String idQues, String strAnswer,Id WID){
        gdc_ms_Question_Answer__c objQuesAns = new gdc_ms_Question_Answer__c();
        objQuesAns.gdc_ms_Question__c = idQues;
        objQuesAns.gdc_ms_Answer__c = strAnswer;
        objQuesAns.gdc_ms_Work_Intake_Form__c = WID;
        return objQuesAns;
   }

    @testSetup static void setup() {
        list<gdc_ms_Question__c> listOfQuestions = new list<gdc_ms_Question__c>();
        listOfQuestions.add(createQuestion('Question1','Text','Intake'));
        listOfQuestions.add(createQuestion('Question2','Checkbox','Intake'));
        listOfQuestions.add(createQuestion('Question3','Text','Intake'));
        insert listOfQuestions;

        gdc_ms_Work_Intake_Form__c  objWIF = new gdc_ms_Work_Intake_Form__c ();
        objWIF.gdc_ms_External_Id__c = 'Test';
        objWIF.Name = 'Test Engagement';
        insert objWIF;
        
        List<gdc_ms_Question_Answer__c> lstQuestionAns = new List<gdc_ms_Question_Answer__c>();
        lstQuestionAns.add(createQuestionAnswer(listOfQuestions[0].Id,'Test',objWIF.Id));
        lstQuestionAns.add(createQuestionAnswer(listOfQuestions[1].Id,'false',objWIF.Id));
        lstQuestionAns.add(createQuestionAnswer(listOfQuestions[2].Id,'',objWIF.Id));
        insert lstQuestionAns;
        
    }
   
    static testmethod void getQuestionsTest(){
        test.startTest();
        List<gdc_ms_Question__c> listOfQuestions =  GDC_MS_QuestionAnswerFormController.getQuestions('gdc_ms_Work_Intake_Form');
        System.assert(listOfQuestions.size() >= 1);
        test.stopTest();
    }

     static testmethod void getQuestionAnswersTest(){
        test.startTest();
        String recordId = [Select Id from gdc_ms_Work_Intake_Form__c LIMIT 1].Id;
        gdc_ms_Work_Intake_Form__c workIntake =  GDC_MS_QuestionAnswerFormController.getQuestionAnswers(recordId);
        System.assert(workIntake!=null);
        test.stopTest();
    }
    
    static testmethod void createRecordsTest(){
        test.startTest();
        List<gdc_ms_Question__c> listOfQuestions = [Select Id from gdc_ms_Question__c];
        String records = '[{"label":"'+listOfQuestions[0].Id+'","value":"Test87","comments":""}]';
        String parentId = GDC_MS_QuestionAnswerFormController.createRecords(records,'Test', null);
        System.assert(parentId!=null);
        test.stopTest();
    }
    
     static testmethod void getListViewIdTest(){
        test.startTest();
        ListView lstView = GDC_MS_QuestionAnswerFormController.getListViewId('gdc_ms_Work_Intake_Form__c');
        System.assert(lstView!=null);
        test.stopTest();
    }

}