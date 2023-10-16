/**
* @Date   December 2021
* @Group  Services Org
* @Description - Test Class for GDC_DA_OB_ReminderNotifyIndMetrics_Batch Class.
*/
@isTest
public class GDCDAOBReminderNotifyIndMetricsBatchTest {
   
    @testsetup static void setup(){
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Apex Test Coverage %',PMD_Tool_Checkbox__c='Yes')); 
        insert projSetup;
        
        
    }
    
    @isTest
    public static void createMetricLITest(){
        //Adding Project
        GDC_DA_Project_Setup__c project = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c limit 1][0];
        //Adding Metric
        GDC_DA_Metric__c metric = new GDC_DA_Metric__c();
        metric.ProjectName__c = project.Id;
        metric.EndDate__c = System.today().addDays(1);
        metric.ProjectName__c = project.id;
        insert metric;
        
        //Add Team Member
       List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
       teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = project.Id, Name__c = userInfo.getUserId(),Active__c=true, Role__c ='Technical Consultant' ) ); 
        
       insert teamMemberList;
        
        //Adding Metric Line Item
        GDC_DA_Metric_Line_Items__c metricLI = new GDC_DA_Metric_Line_Items__c();
        metricLI.name= 'Test';
        metricLI.TotalNumberofLinesinaclass__c = 100;
        metricLI.GDC_DA_Metric__c = metric.id;
        metricLI.Status__c = 'Draft';
        metricLI.GDC_DA_Team_Member__c  = teamMemberList[0].id;
        insert metricLI;
        
        Test.startTest();
       	database.executeBatch(new GDC_DA_OB_ReminderNotifyIndMetrics_Batch()); 
        Test.stopTest();
    }

}