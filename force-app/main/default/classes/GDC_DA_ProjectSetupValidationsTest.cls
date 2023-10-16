@isTest
private class GDC_DA_ProjectSetupValidationsTest {
@testSetup static void setup() {
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1 Test',Region__c ='AMER',Comments__c ='Testing',
                                                  Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                                                  Metric_Entry_End_Date__c =System.today()+90, Metrics_Required__c ='Apex Test Coverage %;',PMD_Tool_Checkbox__c='Yes')); 
        insert projSetup;
        
        //Insert Metrics
        List<GDC_DA_Metric__c> gdcMetrics = new List<GDC_DA_Metric__c >();
        for(Integer i =0; i<2;i++)
        {
            gdcMetrics.add(new GDC_DA_Metric__c(ProjectName__c =projSetup[0].Id));
        }
        
        //Add Team Member
        List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
        teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Role__c ='Sr Technical Consultant' ) ); 
        teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Role__c ='Technical Consultant' ) ); 
        insert teamMemberList;
    }
    
    @isTest static void testMethod1() {
        GDC_DA_Project_Setup__c proj = [Select Id, Name,Region__c,Project_Owner__c,Metrics_Required__c from GDC_DA_Project_Setup__c where Name='Proj1 Test' limit 1];
        proj.Metrics_Required__c = 'Apex Test Coverage %;Code Quality%;Rejected Defect%';
        proj.Is_Project_Completed__c=true;
        update proj;
    }
    
    @isTest static void testProjectOwnerChange()
    {
       
            // creating a user to change GeoLead and test the scenario
            UserContactUtil.doNotExecuteTrigger =true;
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName= uid + '@myorg.com.test');
            insert u;
            List<GDC_DA_Project_Setup__c> proj = [Select Id, Name,Region__c,Project_Owner__c from GDC_DA_Project_Setup__c where Name='Proj1 Test' limit 1];
            proj[0].Project_Owner__c = u.Id;
            update proj;
            System.debug('-Test->'+[Select Project_Owner__c from GDC_DA_Project_Setup__c limit 1].Project_Owner__c);
            System.assertEquals(u.Id, [Select Project_Owner__c from GDC_DA_Project_Setup__c limit 1].Project_Owner__c);
        
    }
}