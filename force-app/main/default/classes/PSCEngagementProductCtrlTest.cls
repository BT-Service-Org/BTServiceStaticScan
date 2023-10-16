@IsTest
public class PSCEngagementProductCtrlTest {
	@TestSetup
    static void makeData(){
        Product_Custom__c proCust = PSCTestDataFactory.createProduct('Product');
        insert proCust;
        
        Method__c met = PSCTestDataFactory.createMethod(128);
        met.Specialized_Resources__c = 'HCC';
        insert met;
        
        Method_by_Product__c metByProd = PSCTestDataFactory.createMethodByProduct(proCust.Id,met.Id);
    }
    
    @isTest
    public static void positiveTest1(){
        Test.startTest();
        PSCEngagementProductCtrl.getProductData('128','Product','Enagement Product','test');
        Test.stopTest();
    }
    @isTest
    public static void positiveTest2(){
        Test.startTest();
        PSCEngagementProductCtrl.getProductData('128','','Specialized Resources','test');
        Test.stopTest();
    }
}