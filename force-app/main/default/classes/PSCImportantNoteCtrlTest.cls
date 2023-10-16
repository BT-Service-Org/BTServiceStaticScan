@IsTest
public class PSCImportantNoteCtrlTest {
	@TestSetup
    static void makeData(){
        
        Method__c met = PSCTestDataFactory.createMethod(128);
        met.Method_Notification_Box__c = 'test';
        insert met;
    }
    
    @isTest
    public static void positiveTest1(){
        
        Test.startTest();
        PSCImportantNoteCtrl.getImportantNoteText(128);
        Test.stopTest();
    }
}