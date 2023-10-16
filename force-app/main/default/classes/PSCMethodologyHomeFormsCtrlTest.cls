@isTest
public class PSCMethodologyHomeFormsCtrlTest {
    @TestSetup
    static void makeData(){
        
        Method__c method = PSCTestDataFactory.createMethod(128);
        insert method;
        
        List<Playbook__c> playbookList = new List<Playbook__c>{PSCTestDataFactory.createPlaybook(PSCConstants.CONTRACT_TYPE_BOTH_ORDER_N_SOW),
                                                                PSCTestDataFactory.createPlaybook(PSCConstants.CONTRACT_TYPE_ORDER_FORM), 
                                                                PSCTestDataFactory.createPlaybook(PSCConstants.CONTRACT_TYPE_SOW)};
        insert playbookList;
        
        Stage__c stage = PSCTestDataFactory.createStage('Discover');
        insert stage;
        
        Role__c role = PSCTestDataFactory.createRole();
        insert role;

        Product_Custom__c prod = PSCTestDataFactory.createProduct('Product');
        insert prod;

        Method_Ownership_By_Product__c mobp = PSCTestDataFactory.createMethodOwnershipByProduct(role.Id, prod.Id, method.Id);
        insert mobp;
    }

    @isTest
    public static void positiveTest1(){
        Test.startTest();
        System.assertEquals(2, PSCMethodologyHomeFormsCtrl.getMethodologyFormData().size(),'SOW and Order Form should be returned');
        Test.stopTest();
    }

}