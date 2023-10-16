@isTest
public without sharing class GDCMSWorkIntakeShareTest {
    
    @IsTest
    public static void shareRecordTest(){
        
        Test.startTest();
        try {
            gdc_ms_Work_Intake_Form__c gdcmswi = new  gdc_ms_Work_Intake_Form__c();
            insert gdcmswi;
            
            Account a = new Account(Name= 'Salesforce.com - DO NOT TOUCH');
            insert a;            
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt1', Email='temproot123@temproot.com', 
                              EmailEncodingKey='UTF-8', LastName='temproot', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fdvf@temproot.com' , Title = 'Director');
            insert u;
            
           /* gdc_ms_Work_Intake_Form__Share workIntakeShare = new gdc_ms_Work_Intake_Form__Share();
            workIntakeShare.ParentId= gdcmswi.Id;
            workIntakeShare.UserOrGroupId= u.Id;
            workIntakeShare.AccessLevel='Read';
            insert workIntakeShare;*/
            
            gdc_ms_Question__c objQues = new gdc_ms_Question__c();
            objQues.gdc_ms_Question__c = 'test';
            objQues.gdc_ms_Required__c = true;
            objQues.gdc_ms_Type__c = 'Text';
            objQues.gdc_ms_Is_Active__c = true;
            objQues.gdc_ms_Category__c = 'Intake';
            insert objQues;
            
            gdc_ms_Question_Answer__c objQuesAns = new gdc_ms_Question_Answer__c();
            objQuesAns.gdc_ms_Question__c = objQues.Id;
            objQuesAns.gdc_ms_Answer__c = 'Test';
            objQuesAns.gdc_ms_Work_Intake_Form__c = gdcmswi.Id;
            insert objQuesAns;
            
            GDCMSWorkIntakeShare.workIntakeShare(new List<Id>{U.iD}, gdcmswi.id, 'Read');
            
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
        
    }
}