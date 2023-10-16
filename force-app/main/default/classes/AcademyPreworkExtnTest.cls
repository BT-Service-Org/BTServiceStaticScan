/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AcademyPreworkExtnTest {

    static testMethod void testStatusUpdate() {
        Academy_Prework__c prework;
        prework = new Academy_Prework__c(   Subject_Area__c='Portals',
                                            Content_Link__c='http://content.com',
                                            Exercise_Link__c='http://exercise.com',
                                            Video_Recording_Link__c='http://video.com');
                                            
        insert prework;
        System.debug('>>>>>>>>prework = '+prework);
        ApexPages.StandardController stdCtlr = new ApexPages.StandardController(prework);
        AcademyPreworkExtension extn = new AcademyPreworkExtension(stdCtlr);
        AcademyPreworkExtension.LinkInput input = new AcademyPreworkExtension.LinkInput();
        input.recordId=prework.id;
        input.linkUrl=prework.Video_Recording_Link__c;
        input.linkType='Video';
        String respUrl = AcademyPreworkExtension.updatePreworkStatus(input);
        prework = [select   Id,Content_Link__c,Exercise_Link__c,Video_Recording_Link__c,
                            Video_Status__c,Content_Status__c,Exercise_Status__c
                   from Academy_Prework__c
                   where Id=:prework.Id];
        System.assertEquals(1,prework.Video_Status__c,'Video Status not updated');
        System.assertEquals(prework.Video_Recording_Link__c,respUrl,'Video url incorrect');
        

        input.linkUrl=prework.Exercise_Link__c;
        input.linkType='Exercise';
        respUrl = AcademyPreworkExtension.updatePreworkStatus(input);
        prework = [select   Id,Content_Link__c,Exercise_Link__c,Video_Recording_Link__c,
                            Video_Status__c,Content_Status__c,Exercise_Status__c
                   from Academy_Prework__c
                   where Id=:prework.Id];
        System.assertEquals(1,prework.Exercise_Status__c,'Exercise Status not updated');
        System.assertEquals(prework.Exercise_Link__c,respUrl,'Exercise url incorrect');

        input.linkUrl=prework.Content_Link__c;
        input.linkType='Content';
        respUrl = AcademyPreworkExtension.updatePreworkStatus(input);
        prework = [select   Id,Content_Link__c,Exercise_Link__c,Video_Recording_Link__c,
                            Video_Status__c,Content_Status__c,Exercise_Status__c
                   from Academy_Prework__c
                   where Id=:prework.Id];
        System.assertEquals(1,prework.Exercise_Status__c,'Content Status not updated');
        System.assertEquals(prework.Content_Link__c,respUrl,'Content url incorrect');
        
    }

    static testMethod void testStatusUpdateNoExercise() {
        Academy_Prework__c prework;
        prework = new Academy_Prework__c(   Subject_Area__c='Portals',
                                            Content_Link__c='http://content.com',
                                            Video_Recording_Link__c='http://video.com');
                                            
        insert prework;
        System.debug('>>>>>>>>prework = '+prework);
        ApexPages.StandardController stdCtlr = new ApexPages.StandardController(prework);
        AcademyPreworkExtension extn = new AcademyPreworkExtension(stdCtlr);
        AcademyPreworkExtension.LinkInput input = new AcademyPreworkExtension.LinkInput();
        input.recordId=prework.id;
        input.linkUrl=prework.Video_Recording_Link__c;
        input.linkType='Video';
        String respUrl = AcademyPreworkExtension.updatePreworkStatus(input);
        prework = [select   Id,Content_Link__c,Exercise_Link__c,Video_Recording_Link__c,
                            Video_Status__c,Content_Status__c,Exercise_Status__c
                   from Academy_Prework__c
                   where Id=:prework.Id];
        System.assertEquals(1,prework.Video_Status__c,'Video Status not updated');
        System.assertEquals(1,prework.Exercise_Status__c,'Exercise Status not updated');
        System.assertEquals(prework.Video_Recording_Link__c,respUrl,'Video url incorrect');
    }


    static testMethod void testAnswers() {
        Academy_Prework__c prework;
        List<Academy_Prework__c> toInsert = new List<Academy_Prework__c>();
        prework = new Academy_Prework__c(   Subject_Area__c='Portals',
                                            Content_Link__c='http://content.com',
                                            Exercise_Link__c='http://exercise.com',
                                            Video_Recording_Link__c='http://video.com');
                                            
        toInsert.add(prework);
        insert toInsert;
        Academy_Question__c q = new Academy_Question__c(Question__c='Some thing',Subject_Area__c='Portals',Academy_Prework__c=prework.Id);
        insert q;
        Candidate_Answer__c answer = new Candidate_Answer__c(Answer_Text__c='Option A',Option__c='A',Question__c=q.Id);
        insert answer;
        ApexPages.StandardController stdCtlr = new ApexPages.StandardController(prework);
        AcademyPreworkExtension extn = new AcademyPreworkExtension(stdCtlr);
        System.assertEquals(1,extn.questions.size(),'PreworkTEmplate controller returned incorrect number of questions');
        System.assertEquals(1,extn.questions.get(0).Candidate_Answers__r.size(),'PreworkTEmplate controller returned incorrect number of answers');
        List<Candidate_Answer__c> answers = extn.questions.get(0).Candidate_Answers__r;
        answers[0].Selected__c=true;
        extn.saveAnswers();
        prework = [select   Id,Content_Link__c,Exercise_Link__c,Video_Recording_Link__c,
                            Video_Status__c,Content_Status__c,Exercise_Status__c,Quiz_Completed_Count__c
                   from Academy_Prework__c
                   where Id=:prework.Id];
        System.assertEquals(1,prework.Quiz_Completed_Count__c,'PreworkTEmplate controller returned incorrect number of answers');
        
    }
}