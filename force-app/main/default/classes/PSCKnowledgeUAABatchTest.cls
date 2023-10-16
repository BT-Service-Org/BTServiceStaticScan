@isTest
public class PSCKnowledgeUAABatchTest {

    static testmethod void PSCKnowledgeUAABatchTest() {
        
         
        
        List<Knowledge__kav> knowledgeList = new List<Knowledge__kav>();
        Knowledge__kav knowledgeOne = PSCTestDataFactory.createKnowledge();
        knowledgeOne.Reviewer__c = UserInfo.getUserId();
        knowledgeOne.OwnerId = UserInfo.getUserId();
        knowledgeOne.Resource_Type__c = 'Sample Deliverables';
        knowledgeList.add(knowledgeOne);
        insert knowledgeList;
        
      
        
        Test.startTest();
        PSCKnowledgeUAABatch Obj = new PSCKnowledgeUAABatch();
        Obj.execute(null, knowledgeList);
        Id jobid= Database.executeBatch(Obj);
        Test.stopTest();
        
        
        
    }
}