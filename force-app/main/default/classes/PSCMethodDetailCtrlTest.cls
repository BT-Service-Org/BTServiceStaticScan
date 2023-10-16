@IsTest
public class PSCMethodDetailCtrlTest {
	@TestSetup
    static void makeData(){
        Method__c met = PSCTestDataFactory.createMethod(128);
        met.Specialized_Resources__c = 'HCC';
        insert met;
    }
    
    @isTest
    public static void positiveTest1(){
        Test.startTest();
        PSCMethodDetailCtrl.getTableOfContentsValues('test');
        PSCMethodDetailCtrl.getMethodId(128);
        Test.stopTest();
    }
}