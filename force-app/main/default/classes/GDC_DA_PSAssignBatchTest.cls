@isTest
public class GDC_DA_PSAssignBatchTest {
	
    @testSetup static void setup() {
        Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'stad', Email='temproot@gdcda.com', 
                          EmailEncodingKey='UTF-8', LastName='gdcda', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot@gdcda.com' , Title = 'Director');
        insert u;
        
        User u1 = new User(Alias = 'stad', Email='temproot1@gdcda.com', 
                          EmailEncodingKey='UTF-8', LastName='gdcda1', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='temproot1@gdcda.com' , Title = 'Delivery Manager');
        u1.Mgmt_Chain_Hierarchy_Level_06__c = u.Id;
        insert u1;
        
        
        User u2 = new User(Alias = 'standt', Email='tempmember@gdcda.com', 
                          EmailEncodingKey='UTF-8', LastName='tempmember', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tempmember@gdcda.com', Title = 'Technical Consultant');
        u2.Mgmt_Chain_Hierarchy_Level_06__c = u.Id;
        insert u2;
        
    }
    
    static testMethod void testBatch() {
        User u = [Select Id from USER where LastName = 'gdcda' LIMIT 1];
        GDCDAPermission__c  cs = new GDCDAPermission__c();
        cs.userid__c = u.Id;
        cs.fieldname__c = 'Mgmt_Chain_Hierarchy_Level_06__c';
        insert cs;
        test.startTest();
        GDC_DA_PSAssignBatchScheduler obj = new GDC_DA_PSAssignBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, obj );
        test.stopTest();
        
    }
    
}