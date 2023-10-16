@isTest
public with sharing class PSCFavoriteCtrlTest {
    @testSetup
    static void createData() {
        test.startTest();
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser  
                           FROM User 
                           WHERE Id=:userinfo.getUserId() 
                           AND UserPermissionsKnowledgeUser=false 
                           LIMIT 1];
        if(user != null && !user.isEmpty()){
            user[0].UserPermissionsKnowledgeUser = true;
            update user;
        }
		test.stopTest();        
        Knowledge__kav kObj = PSCTestDataFactory.createKnowledge();

        insert kObj;
        
    }

    @isTest
    public static void positiveTest1(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser  
                           FROM User 
                           WHERE Id=:userinfo.getUserId()  
                           LIMIT 1];
        
        List<KnowledgeArticle > knowledgeArticle = [SELECT Id
                                         FROM KnowledgeArticle 
                                         LIMIT 1];
        system.runAs(user[0]){
            KbManagement.PublishingService.publishArticle(knowledgeArticle[0].Id, true);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PSCFavoriteCtrlMock.GetFavoriteSuccess());
        PSCFavoriteCtrl.createFavorite(knowledgeArticle[0].Id, 'test');
        PSCFavoriteCtrl.getUserFavorite();
        system.assertEquals(204, PSCFavoriteCtrl.deleteUserFavorite('favId'),'Successesfully deleted.');
        
        Test.stopTest();
    }
}