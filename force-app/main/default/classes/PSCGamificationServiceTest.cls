@isTest
public class PSCGamificationServiceTest {
@TestSetup
    static void createData(){
        
        List<Knowledge__kav> knowledgeList = new List<Knowledge__kav>();
        Knowledge__kav knowledgeOne = PSCTestDataFactory.createKnowledge();
        knowledgeOne.Reviewer__c = UserInfo.getUserId();
        knowledgeOne.Resource_Type__c = 'Sample Deliverables';
        knowledgeOne.UrlName = 'test-title1';
        knowledgeList.add(knowledgeOne);
        
        Knowledge__kav knowledgeTwo = PSCTestDataFactory.createKnowledge();
        knowledgeTwo.Reviewer__c = UserInfo.getUserId();
        knowledgeTwo.Resource_Type__c = 'Best Practices';
        knowledgeTwo.UrlName = 'test-title2';
        knowledgeList.add(knowledgeTwo);
        
        Knowledge__kav knowledgeThree = PSCTestDataFactory.createKnowledge();
        knowledgeThree.Reviewer__c = UserInfo.getUserId();
        knowledgeThree.Resource_Type__c = 'Standards';
        knowledgeThree.UrlName = 'test-title3';
        knowledgeList.add(knowledgeThree);
        
        Knowledge__kav knowledgeFour = PSCTestDataFactory.createKnowledge();
        knowledgeFour.Reviewer__c = UserInfo.getUserId();
        knowledgeFour.Resource_Type__c = 'Product & Industry Knowledge';
        knowledgeFour.UrlName = 'test-title4';
        knowledgeList.add(knowledgeFour);
        
        Knowledge__kav knowledgeFive = PSCTestDataFactory.createKnowledge();
        knowledgeFive.Reviewer__c = UserInfo.getUserId();
        knowledgeFive.Resource_Type__c = 'Reusable Assets';
        knowledgeFive.UrlName = 'test-title5';
        knowledgeList.add(knowledgeFive);   
        
        insert knowledgeList;
    }
    
    @isTest
    public static void createKnowledgeRelatedUAATest(){
    
        List<Knowledge__kav> knowledgeList = [Select Id,Reviewer__c,Resource_Type__c,OwnerId From Knowledge__kav
                                             Where Reviewer__c =:UserInfo.getUserId() and (Resource_Type__c = 'Sample Deliverables' or
                                                   Resource_Type__c = 'Best Practices' or
                                                   Resource_Type__c = 'Standards' or
                                                   Resource_Type__c = 'Product & Industry Knowledge' or
                                                   Resource_Type__c = 'Reusable Assets')];
        
        test.startTest();
        PSCGamificationService.createKnowledgeRelatedUAA(knowledgeList);
        test.stoptest();
        List<String> knowledgeIdList = new List<String>();
        for(Knowledge__kav knowledge:knowledgeList){
            knowledgeIdList.add(knowledge.Id);
        }
        User_Achievement_Activity__c uaa = [Select Id from User_Achievement_Activity__c where Knowledge__c =:knowledgeIdList Limit 1];
        System.assertNotEquals(null, uaa, 'Method should return data');
    }
}