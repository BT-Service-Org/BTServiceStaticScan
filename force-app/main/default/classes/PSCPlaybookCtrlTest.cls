@isTest
public class PSCPlaybookCtrlTest {
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

        Product_Custom__c prod1 = PSCTestDataFactory.createProduct('Product');
        prod1.recordTypeId = Schema.SObjectType.Product_Custom__c.getRecordTypeInfosByDeveloperName().get('Service_Offering').getRecordTypeId();
        insert prod1;

        Method_Ownership_By_Product__c mobp = PSCTestDataFactory.createMethodOwnershipByProduct(role.Id, prod.Id, method.Id);
        insert mobp;

        Method_Ownership_By_Product__c mobp1 = PSCTestDataFactory.createMethodOwnershipByProduct(role.Id, prod1.Id, method.Id);
        insert mobp1;
    }
	@isTest
    public static void getHeaderNavigationIdTest1(){
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('SOW','playbooks')!=null,'success');
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('test;test','playbooks')!=null,'success');
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('test','allStages')!=null,'success');
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('test','roles')!=null,'success');
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('test','productOfferings')!=null,'success');
        system.assert(PSCPlaybookCtrl.getAllPlayBookInfo('test','serviceOfferings')!=null,'success');
    }
}