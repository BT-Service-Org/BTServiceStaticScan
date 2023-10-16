@isTest
public class GDC_MS_TeamMemberBatch_SchedulableTest {
    @testSetup static void setup() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='temproot@temproot.com', 
                          EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot@temproot.com' , Title = 'Director');
        insert u;
        
        User u2 = new User(Alias = 'standt', Email='tempmember@tempmember.com', 
                          EmailEncodingKey='UTF-8', LastName='tempmember', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tempmember@tempmember.com', Title = 'Delivery Manager');
        u2.Mgmt_Chain_Hierarchy_Level_06__c = u.Id;
        u2.ManagerId = u.Id;
        insert u2;
    }
    
    
    public testmethod static void testRunSchedulable(){
        User u = [Select Id from USER where LastName = 'temproot' LIMIT 1];
        GDC_MS_RootTeamMember__c  mc = new GDC_MS_RootTeamMember__c();
        mc.gdc_ms_RootTeamMemberID__c = u.Id;
        mc.gdc_ms_RootTeamMemberFieldName__c = 'Mgmt_Chain_Hierarchy_Level_06__c';
        insert mc;
        Test.startTest();
        GDC_MS_TeamMemberBatch_Schedulable obj = new GDC_MS_TeamMemberBatch_Schedulable();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, obj );
        Test.stopTest();
    }
    
}