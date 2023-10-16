@isTest
public with sharing class methodCreationScreen11ControllerTest {
  
    @isTest
    public static void testgetSpecialistCloudRecords(){
        Specialist_Cloud__c sc = new Specialist_Cloud__c();
        sc.Name = 'Core';
        insert sc;
        
        Method__c method = new Method__c();
        method.Name = 'Test Method';
        method.Status__c = 'Draft';
        insert method;

        Method_by_Specialist_Cloud__c msc = new Method_by_Specialist_Cloud__c();
        msc.method__c = method.Id;
        msc.Specialist_Cloud__c = sc.Id;
        msc.Status__c = 'Does Not Apply';
        insert msc;

        methodCreationScreen11Controller.getSpecialistCloudRecords(method.Id);
        methodCreationScreen11Controller.getSpecialistCloudRecords('');
    }
}