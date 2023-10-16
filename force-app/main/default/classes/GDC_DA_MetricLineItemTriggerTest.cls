@isTest
private class GDC_DA_MetricLineItemTriggerTest {
	
    @testSetup static void setup() {
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Apex Test Coverage %',PMD_Tool_Checkbox__c='Yes')); 
        insert projSetup;
       
       //Add Team Member
       List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
       teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Active__c=true, Role__c ='Technical Consultant' ) ); 
       insert teamMemberList;
    }
    
    @isTest
    static void updateStatusTest(){
        GDC_DA_Metric_Line_Items__c item = [SELECT id from GDC_DA_Metric_Line_Items__c limit 1];
        item.LinescoveredbyTestClass__c = 100;
        item.TotalNumberofLinesinaclass__c = 100;        
        update item;
        
        GDC_DA_Metric_Line_Items__c updateditem = [SELECT id,Status__c from GDC_DA_Metric_Line_Items__c where id =: item.Id];
        System.assertEquals('Submitted', updateditem.Status__c);
    }
    
    @isTest
    static void createIndividualMetricsTest(){
        List<GDC_DA_Metric__c> metrics = [SELECT id from GDC_DA_Metric__c];
        
        GDC_DA_Project_Setup__c project = [SELECT id from GDC_DA_Project_Setup__c limit 1];
        project.Metrics_Required__c = 'Apex Test Coverage %;Code Quality%;Rejected Defect%';
        project.Metric_Entry_End_Date__c =System.today()+40;
        update project;
        
         List<GDC_DA_Metric__c> updatedmetrics = [SELECT id from GDC_DA_Metric__c];
        System.assertNotEquals(metrics.size(), updatedmetrics.size());
    }
}