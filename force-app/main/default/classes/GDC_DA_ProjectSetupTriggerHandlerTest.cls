@isTest
private class GDC_DA_ProjectSetupTriggerHandlerTest {
	
    @testSetup static void setup() {
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Apex Test Coverage %;Code Quality%;Rejected Defect%',PMD_Tool_Checkbox__c='Yes')); 
        /*projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj2',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Weekly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Apex Test Coverage %;Code Quality%;Rejected Defect%',PMD_Tool_Checkbox__c='Yes'));
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj3',Region__c ='AMER',Comments__c ='Testing',
                      Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Monthly',
                      Metric_Entry_End_Date__c =System.today()+30, Metrics_Required__c ='Apex Test Coverage %;Code Quality%;Rejected Defect%',PMD_Tool_Checkbox__c='Yes'));*/
        insert projSetup;
       
       //Add Team Member
       List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
       teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Start_Date__c = System.today(),End_Date__c =System.today()+30,Active__c=false, Role__c ='Technical Consultant' ) ); 
       insert teamMemberList;
    }
    
    @isTest
    static void updateProjectDetails(){
        Test.startTest();
        GDC_DA_Project_Setup__c project = [SELECT id from GDC_DA_Project_Setup__c limit 1];
        project.Metrics_Required__c = 'Code Quality%;Apex Test Coverage %;Rejected Defect%';
        project.Metric_Entry_End_Date__c =System.today()+40;
        project.Active__c = true;
        update project;
        Test.stopTest();
    }
    
    @isTest
    static void deactivateProject(){
        Test.startTest();
        GDC_DA_Project_Setup__c project = [SELECT id from GDC_DA_Project_Setup__c limit 1];
        project.Metrics_Required__c = 'Code Quality%;Apex Test Coverage %;Rejected Defect%';
        project.Metric_Entry_End_Date__c =System.today()+40;
        project.Active__c = true;
        update project;
        // deactivate project, teammembers
        project.Active__c = false;
        update project;
        Test.stopTest();
    }
}