@IsTest
public class PSCTemplateBestPracticeCtrlTest {
	@TestSetup
    static void makeData(){
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
        
        Method__c met = PSCTestDataFactory.createMethod(128);
        insert met;
        
        ContentVersion file = PSCTestDataFactory.createFile();
        insert file;
        
        List<ContentDocument> conDoc = [SELECT Id
                                       FROM ContentDocument
                                       LIMIT 1];
            
        ContentDocumentLink conDocLink = PSCTestDataFactory.createContentDocLink(conDoc[0].Id,met.Id);
        insert conDocLink;
        
        Article_Method__c artMet = PSCTestDataFactory.createArticleMethod(kObj.Id,met.Id);
        insert artMet;
        
        Templates__c temp = PSCTestDataFactory.createtemplate(met.Id);
        insert temp;
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
        PSCTemplateBestPracticeCtrl.getTemplateData([SELECT Id FROM Method__c WHERE Method_Number__c = 128]?.Id);
        Test.stopTest();
    }
}