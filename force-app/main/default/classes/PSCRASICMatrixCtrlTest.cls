@IsTest
public class PSCRASICMatrixCtrlTest {
	@TestSetup
    static void makeData(){
        
        Method__C method = PSCTestDataFactory.createMethod(456);
        insert method;

        Activity__c act = PSCTestDataFactory.createActivity();
        insert act;
        
        Role__c role = PSCTestDataFactory.createRole();
        insert role;

        Method_By_Activity__c metAct = PSCTestDataFactory.createMethodActivity(method.Id, act.Id);
        insert metAct;        

        Activity_Ownership__c actOwn = PSCTestDataFactory.createActivityOwnerShip(act.Id,role.Id);
        insert actOwn;
    }
    
    @isTest
    public static void positiveTest1(){
        List<Method__c> methodList = [SELECT Id
                                     FROM Method__c 
                                     LIMIT 1];
        Test.startTest();
        PSCRASICMatrixCtrl.getRasicData(methodList[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void positiveTest2(){
        List<Method__c> methodList = [SELECT Id
                                     FROM Method__c 
                                     LIMIT 1];
        
        Activity__c act = PSCTestDataFactory.createActivity();
        act.Name = 'New Test';
        insert act;
        
        Role__c role = PSCTestDataFactory.createRole();
        role.Name = 'New Role Test';
        insert role;

        Method_By_Activity__c metAct = PSCTestDataFactory.createMethodActivity(methodList[0].Id, act.Id);
        insert metAct;        

        Activity_Ownership__c actOwn = PSCTestDataFactory.createActivityOwnerShip(act.Id,role.Id);
        insert actOwn;
        
        Test.startTest();
        PSCRASICMatrixCtrl.getRasicData(methodList[0].Id);
        Test.stopTest();
    }
}