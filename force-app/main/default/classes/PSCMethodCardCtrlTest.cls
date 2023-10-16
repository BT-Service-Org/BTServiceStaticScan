@isTest
public class PSCMethodCardCtrlTest {
    
    @TestSetup
    static void makeData(){
        
        Method__C method = PSCTestDataFactory.createMethod(456);
        insert method;

        Grouping__c group1 = PSCTestDataFactory.createGrouping('group1');
        insert group1;

        Stage__c stage1 = PSCTestDataFactory.createStage('stage1');
        insert stage1;

        Method_by_Grouping__C methodGrouping = PSCTestDataFactory.createMethodByGrouping(method.Id, group1.Id);
        insert methodGrouping;

        Method_with_Stage__c methodStage = PSCTestDataFactory.createMethodByStaging(method.Id, stage1.Id);
        insert methodStage;
    }

    @isTest
    public static void positiveTest1(){
        Test.startTest();
        System.assertNotEquals(null, PSCMethodDetailCtrl.getMethodId(456), 'Success');
        System.assertEquals(1, PSCMethodCardCtrl.getMethodCardData(new List<Double>{456}).size(),'Success');
        Test.stopTest();
    }
}