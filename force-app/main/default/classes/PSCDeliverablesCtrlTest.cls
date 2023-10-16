@isTest
public class PSCDeliverablesCtrlTest {
    @TestSetup
    static void makeData(){
        
        Method__C method = PSCTestDataFactory.createMethod(128);
        insert method;

        Deliverables__c deliverableObj = PSCTestDataFactory.createDeliverable();
        insert deliverableObj;

        Method_by_Deliverables__c methodByDeliverables = PSCTestDataFactory.createMethodByDeliverable(method.Id, deliverableObj.Id);
        insert methodByDeliverables;
    }

    @isTest
    public static void positiveTest1(){
        Method__c method = [SELECT Id FROM Method__c LIMIT 1];
        Test.startTest();
        System.assertEquals(1, PSCDeliverablesCtrl.getDeliverablesList(method.Id).size(),'Deliverable should be returned');
        Test.stopTest();
    }

    @isTest
    public static void negativeTest1(){
        Method__C method = PSCTestDataFactory.createMethod(129);
        insert method;
        Test.startTest();
        System.assertEquals(0, PSCDeliverablesCtrl.getDeliverablesList(method.Id).size(),'Empty result should return');
        Test.stopTest();
    }

    @isTest
    public static void negativeTest2(){
        Test.startTest();
        System.assertEquals(0, PSCDeliverablesCtrl.getDeliverablesList(null).size(),'Empty result should return');
        Test.stopTest();
    }

}