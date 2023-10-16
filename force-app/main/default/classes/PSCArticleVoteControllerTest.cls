@isTest
public class PSCArticleVoteControllerTest {
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
        System.debug('user->'+user);
        List<KnowledgeArticle > knowledgeArticle = [SELECT Id
                                         FROM KnowledgeArticle 
                                         LIMIT 1];
        system.runAs(user[0]){
            KbManagement.PublishingService.publishArticle(knowledgeArticle[0].Id, true);
        }
        
        Vote vote = PSCArticleVoteController.upsertUserVote(knowledgeArticle[0].Id,'5',null);
        
        System.assertEquals(1, PSCArticleVoteController.getVoteCount(knowledgeArticle[0].Id).upVoteCount,'Upvote registered') ;
        PSCArticleVoteController.getUserVote(knowledgeArticle[0].Id);
        PSCArticleVoteController.upsertUserVote(null,'1',vote.Id);
        System.assertEquals(1, PSCArticleVoteController.getVoteCount(knowledgeArticle[0].Id).downVoteCount,'Downvote registered') ;
        PSCArticleVoteController.getVoteCount(knowledgeArticle[0].Id);
    }
}