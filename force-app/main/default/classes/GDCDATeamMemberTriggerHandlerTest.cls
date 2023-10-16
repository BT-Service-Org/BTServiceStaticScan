/**
* @Date   December 2021
* @Group  Services Org
* @Description - Test Class for GDCDATeamMemberTriggerHandler Class.
*/
@isTest
public class GDCDATeamMemberTriggerHandlerTest {
    @testSetup static void setup() {
        // Create Projects
        List<GDC_DA_Project_Setup__c > projSetup = new List<GDC_DA_Project_Setup__c >();
        projSetup.add(new GDC_DA_Project_Setup__c(Name='Proj1',Region__c ='AMER',Comments__c ='Testing',
                                                  Project_Owner__c =userInfo.getUserId(),Metric_Entry_Start_Date__c =System.today(),Metric_Entry_Interval__c ='Fortnightly',
                                                  Metric_Entry_End_Date__c =System.today()+90,Active__c = true, Metrics_Required__c ='Apex Test Coverage %;Code Quality%;Rejected Defect%',PMD_Tool_Checkbox__c='Yes')); 
        insert projSetup;
        
        //Insert Metrics
        
        //Add Team Member
        List<GDC_DA_Team_Member__c> teamMemberList = new List<GDC_DA_Team_Member__c>();
        teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Start_Date__c = System.today(),End_Date__c =System.today()+30,Active__c=true,Role__c ='Sr Technical Consultant' ) ); 
        teamMemberList.add(new GDC_DA_Team_Member__c( Project__c = projSetup[0].Id, Name__c = userInfo.getUserId(),Start_Date__c = System.today(),End_Date__c =System.today()+30,Active__c=true,Role__c ='Technical Consultant' ) ); 
        insert teamMemberList;
    }
    
    @isTest static void testMethod1() {
        
        List<GDC_DA_Team_Member__c> allTeamMembers = [Select Id, Active__c from GDC_DA_Team_Member__c];
        List<GDC_DA_Team_Member__c> TMsToUpdate = new List<GDC_DA_Team_Member__c> ();
        for(GDC_DA_Team_Member__c dtm : allTeamMembers)
        {
            dtm.Active__c = false;
            TMsToUpdate.add(dtm);
        }
        try{
            update TMsToUpdate;
            
            TMsToUpdate[0].Active__c = true;
            update TMsToUpdate;
           
        }
        catch(Exception e)
        {
            System.debug('exception '+e.getMessage());
        }
    }
}