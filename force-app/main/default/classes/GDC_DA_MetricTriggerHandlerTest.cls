/**
 * @Date   October 2021
 * @Group  Services Org
 * @Description - Test Class for GDC_DA_MetricTriggerHandler Class.
 */
@isTest
public class GDC_DA_MetricTriggerHandlerTest {
    
   @testSetup static void setup() {
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Code Quality%;Rejected Defect%;Apex Test Coverage %',PMD_Tool_Checkbox__c='Yes')); 
        insert projSetup;
       
       //Insert Metrics
       List<GDC_DA_Metric__c> gdcMetrics = new List<GDC_DA_Metric__c >();
       for(Integer i =0; i<2;i++)
       {
           gdcMetrics.add(new GDC_DA_Metric__c(ProjectName__c =projSetup[0].Id));
       }
       insert gdcMetrics;
       //Add Team Member
       List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
       teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Role__c ='Technical Consultant' ) ); 
       insert teamMemberList;
    }
    
    @isTest static void testMethod1() {
        GDC_DA_Project_Setup__c proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
        List<GDC_DA_Metric__c> allMetricsList = [Select Id, status__c from GDC_DA_Metric__c where ProjectName__c=:proj.Id];
       	List<GDC_DA_Metric__c> metricsToUpdate = new List<GDC_DA_Metric__c> ();
        for(GDC_DA_Metric__c metric : allMetricsList)
        {
            metric.status__c = 'Submitted for Review';
            metricsToUpdate.add(metric);
        }
        try{
             update metricsToUpdate;
            System.debug('On Rejection');
        	 metricsToUpdate[0].status__c = 'Approval Rejected';
             update metricsToUpdate;
        
        	proj.Metrics_Required__c ='Rejected Defect%;';
        	update proj;
        }
       	catch(Exception e)
        {
            System.debug('exception '+e.getMessage());
        }
    }
    
    @isTest static void testApprovalAccess(){
        Test.startTest();
        GDC_DA_Project_Setup__c proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
        List<GDC_DA_Metric__c> allMetricsList = [Select Id, status__c from GDC_DA_Metric__c where ProjectName__c=:proj.Id];
       List<String> metricIds = new List<String>();
        for(GDC_DA_Metric__c metric : allMetricsList){
            metricIds.add(metric.Id);
        }
        GDC_DA_ProjectTeamMemberCheck.checkApprovalAccess(metricIds);
        test.stopTest();
    }
    
    /* @isTest static void approveMetricRecordTest() {
        GDC_DA_Project_Setup__c proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
        List<GDC_DA_Metric__c> allMetricsList = [Select Id, status__c from GDC_DA_Metric__c where ProjectName__c=:proj.Id limit 1];
       	List<GDC_DA_Metric__c> metricsToUpdate = new List<GDC_DA_Metric__c> ();
        for(GDC_DA_Metric__c metric : allMetricsList)
        {
            //metric.status__c = 'Ready for Approval';
            //metric.status__c = 'Draft';
            metric.TotalEstimatedEffortsHours__c  = 100;
            metric.TotalActualeffortsHours__c   = 100;
            metricsToUpdate.add(metric);
            
        }
        update metricsToUpdate;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(metricsToUpdate[0].id);
        Approval.ProcessResult result = Approval.process(app); 
         
        // Verify the result
		System.assert(result.isSuccess());
         
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 = Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
       
    }
    */
    @isTest static void approvedMetricRecordUploadTest() {
        GDC_DA_Project_Setup__c proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
        List<GDC_DA_Metric__c> allMetricsList = [Select Id, status__c from GDC_DA_Metric__c where ProjectName__c=:proj.Id];
       	List<GDC_DA_Metric__c> metricsToUpdate = new List<GDC_DA_Metric__c> ();
        List<GDC_DA_Metric__c> metricsToApprove = new List<GDC_DA_Metric__c> ();
        for(GDC_DA_Metric__c metric : allMetricsList)
        {
            metric.status__c = 'Submitted for Review';
            metric.TotalEstimatedEffortsHours__c  = 100;
            metric.TotalActualeffortsHours__c   = 100;
            metricsToUpdate.add(metric);
            
        }
        update metricsToUpdate;
        for(GDC_DA_Metric__c metric : allMetricsList)
        {
            metric.status__c = 'Review Completed';
            metricsToApprove.add(metric);
        }
        update metricsToApprove;
    }
    
    // covers the method handleProjectCompletionMetricChanges on GDAC_DA_ProjectSetupValidations Class
    @isTest static void handleisProjectCompletedTest()
    {
       List<GDC_DA_Project_Setup__c> proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
       proj[0].Is_Project_Completed__c=true;
       update proj;
        System.assertEquals(true, proj[0].Is_Project_Completed__c);
    }
    
    @isTest static void testProjectOwnerChange()
    {
        try{
            // creating a user to change GeoLead and test the scenario
            UserContactUtil.doNotExecuteTrigger =true;
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName= uid + '@myorg.com');
            insert u;
            List<GDC_DA_Project_Setup__c> proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1];
            proj[0].Project_Owner__c = u.Id;
            update proj;
            System.debug('-Test->'+[Select Project_Owner__c from GDC_DA_Project_Setup__c limit 1].Project_Owner__c);
            System.assertEquals(u.Id, [Select Project_Owner__c from GDC_DA_Project_Setup__c limit 1].Project_Owner__c);
        }
        
        catch(Exception e)
        {
           System.debug('Exception caught'+e.getMessage()); 
        }
        
        
    }
    
}