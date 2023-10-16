@isTest
public class PSCKnowledgeUAABatchSchedulerTest {
    
    @isTest
    public static void testPSCKnowledgeUAABatchScheduler(){
        
        String cronExpr = '0 0 0 * * ? *';
        Test.startTest();
        PSCKnowledgeUAABatchScheduler Obj= new PSCKnowledgeUAABatchScheduler();
        String jobId = System.schedule('PSCKnowledgeUAABatchScheduler', cronExpr, Obj);
        Obj.execute(null);
        Test.stopTest();
    }
    
    
}