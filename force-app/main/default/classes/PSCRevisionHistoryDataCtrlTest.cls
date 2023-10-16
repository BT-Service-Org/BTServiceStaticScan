@isTest
public class PSCRevisionHistoryDataCtrlTest {
    
    @TestSetup
    static void makeData(){
        Method__c method1 = PSCTestDataFactory.createMethod(123);
        insert method1;

        Methodology_Version__C mvObj = PSCTestDataFactory.createMethodVersion(method1.Id);
        insert mvObj;
    }

    @isTest
    public static void positiveTest1(){
        Test.startTest();
        System.assertEquals(1, PSCRevisionHistoryDataCtrl.getMethodologyVersionData('123').size(),'Success');
        Test.stopTest();
    }
}