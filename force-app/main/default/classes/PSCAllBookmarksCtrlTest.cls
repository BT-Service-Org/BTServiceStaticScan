@isTest
public class PSCAllBookmarksCtrlTest {
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
        kObj.Include_in_Slack_Journey__c = 'Method Assignment';
        insert kObj;
    }
    
    @isTest
    public static void positiveAllBookmarksTest1(){
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
        PSCAllBookmarksCtrl.getPSCBookmarkedArticles('All Bookmarks');
        
        Test.stopTest();
    }
    
    @isTest
    public static void positiveAllRecommendationsTest1(){
        List<User> user = [SELECT Id, UserPermissionsKnowledgeUser  
                           FROM User 
                           WHERE Id=:userinfo.getUserId()  
                           LIMIT 1];
        
        List<KnowledgeArticle > knowledgeArticle = [SELECT Id
                                         FROM KnowledgeArticle 
                                         LIMIT 1];
        
        List<Knowledge__kav > knowledge = [SELECT Id
                                         FROM Knowledge__kav 
                                         LIMIT 1];
        
        system.runAs(user[0]){
            KbManagement.PublishingService.publishArticle(knowledgeArticle[0].Id, true);
        }
        
        Contact con = PSCTestDataFactory.createContact();
        con.User_Record__c = user[0].Id;
        insert con;
        
        PSA_Project__c pro = PSCTestDataFactory.createProject('ExternalClient');
        insert pro;
        
        Project_Assignment__c proAss = PSCTestDataFactory.createProjectAssignment(pro.Id,con.Id);
        insert proAss;
        
        Product_Custom__c prod = PSCTestDataFactory.createProduct('Product');
        insert prod;
        
        Project_by_Product_Offerings__c projProdOff = PSCTestDataFactory.createProjectByProOff(pro.Id,prod.Id);
        insert projProdOff;
            
        Article_Product__c artProd = PSCTestDataFactory.createArticleProduct(knowledge[0].Id,prod.Id);
        insert artProd;

        Test.startTest();
        
        PSCAllBookmarksCtrl.getPSCBookmarkedArticles('All Recommendations');
        
        Test.stopTest();
    }
}