@isTest
public class PSCFeedbackContributionCtrlTest {
    @TestSetup
    static void makeData(){  
        Test.startTest();
            List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User 
                            WHERE Id=:userinfo.getUserId() LIMIT 1];
            if(user != null && !user.isEmpty()){
                user[0].UserPermissionsKnowledgeUser = true;
                update user;
            }
		Test.stopTest();   
        
        Method__c method = PSCTestDataFactory.createMethod(128);
        insert method;

        Feedback_for_Method__c feedbackForMethod = PSCTestDataFactory.createFeedbackForMethod(method.Id, 'Method_Feedback');
        insert feedbackForMethod;

        //Creating content document
        ContentVersion file = PSCTestDataFactory.createFile();
        insert file;
    }

    @isTest
    public static void getFeedbackDataTest(){
        Test.startTest();
            List<PSCFeedbackContributionCtrl.FeedbackButtonWrapper> feedbackButtonList = PSCFeedbackContributionCtrl.getFeedbackData();
        Test.stopTest();
        System.assertEquals(true, feedbackButtonList != null,'Feedback data should return the list');
    }

    @isTest
    public static void updateContentDocumentLinkTest(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser FROM User WHERE Id = :userinfo.getUserId() LIMIT 1];
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument LIMIT 1];
        List<Feedback_for_Method__c> feedbackForMethodList = [SELECT Id FROM Feedback_for_Method__c LIMIT 1];
        System.runAs(user[0]){
            PSCFeedbackContributionCtrl.updateContentDocumentLink(JSON.serialize(new List<Id>{conDocList[0].Id}), feedbackForMethodList[0].Id);
        }
        List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink Where ContentDocumentId = :conDocList[0].Id AND LinkedEntityId = :feedbackForMethodList[0].Id];
        System.assertEquals(true, contentLinkList != null && !contentLinkList.isEmpty(),'Content Link should be not empty');
        System.assertEquals(feedbackForMethodList[0].Id, contentLinkList[0].LinkedEntityId ,'Content Link should be associated to the Feedback Record');
    }
}