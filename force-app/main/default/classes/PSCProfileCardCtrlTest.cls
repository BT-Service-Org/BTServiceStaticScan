@isTest
public class PSCProfileCardCtrlTest {
    @TestSetup
    static void makeData(){  
        
        Test.startTest();
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser,Total_Points__c FROM User 
                           WHERE Id=:userinfo.getUserId() LIMIT 1];
        if(user != null && !user.isEmpty()){
            user[0].UserPermissionsKnowledgeUser = true;
            user[0].Total_Points__c = 100;
            update user;
        }
		Test.stopTest();   
        
        //Creating the knowledge
        Knowledge__kav knowledge1 = PSCTestDataFactory.createKnowledge();
        insert knowledge1;
        Knowledge__kav knowledge2 = PSCTestDataFactory.createKnowledge();
        knowledge2.UrlName = 'test-reviewer';
        knowledge2.Reviewer__c = user[0].Id;
        insert knowledge2;
        //Creating article Feedback
        Article_Feedback__c articleFeedback = PSCTestDataFactory.createArticleFeedback(knowledge1.Id, 'Up');
        insert articleFeedback;
    }

    @isTest
    public static void getProfileCardDetailsTest(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser  
                           FROM User 
                           WHERE Id=:userinfo.getUserId()  
                           LIMIT 1];
        
        List<KnowledgeArticle > knowledgeArticle = [SELECT Id
                                         FROM KnowledgeArticle 
                                         LIMIT 2];
        system.runAs(user[0]){
        	KbManagement.PublishingService.publishArticle(knowledgeArticle[0].Id, true);
            KbManagement.PublishingService.publishArticle(knowledgeArticle[1].Id, true);
        }
        PSCProfileCardCtrl.ProfileCardWrapperOuter profileCardObj;
        Test.startTest();
            profileCardObj = PSCProfileCardCtrl.getProfileData();
        Test.stopTest();
        
        System.assertNotEquals(null, profileCardObj, 'Method should return data');
   
    }
}