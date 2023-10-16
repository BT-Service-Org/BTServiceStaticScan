@isTest
public class EDHQ_BT_SmartSheet_SlackPublisherTest {
    @TestSetup
    static void createData(){
        MethodologyTestHelper.setupBaseDataForSlackTriggerBatch();
    }
    
    @IsTest
    static void testSlackMsgHttpPostCallout() {        
        
        MTH_SlackApiHandlerInterface mockHandler = MethodologyTestHelper.createMockSlackApiHandler();
        MTH_SlackUserIdHandler.slackApiHandler =  mockHandler;
        MTH_SlackMessageSender.slackApiHandler = mockHandler;
        
        Contact contact3  = new Contact(FirstName='Test', LastName='Contact3',User_Record__c = UserInfo.getUserId());
        insert contact3;
        
        PSA_Project__c psaProject = new PSA_Project__c();
		psaProject.Name = 'Test Project';
        psaProject.SmartSheet_Link__c = 'WWW.Google.Com';
        psaProject.Start_Date__c = System.today();
        psaProject.End_Date__c = System.today() + 10;
        psaProject.Org62_Id__c = 'test1234';
        insert psaProject;
        
        Project_Assignment__c assignment3 = new Project_Assignment__c();
        assignment3.Resource__c = contact3.Id;
        assignment3.Project_Role__c = 'Project Manager';
        assignment3.PSA_Project__c = psaProject.Id;
        assignment3.Start_Date__c = Date.today();
        assignment3.Org62_Id__c = 'testId3';
        insert assignment3;
        
        Test.startTest();
        EDHQ_BT_SmartSheet_SlackPublisher.SlackMsgHttpPostCallout(new List<PSA_Project__c>{ psaProject });
        Test.stopTest();

        //PSA_Project__c updatedProject = [SELECT Project_Setup_Status__c FROM PSA_Project__c WHERE Name = :MethodologyTestHelper.TEST_PROJECT_NAME LIMIT 1];
        //System.assertEquals(Label.Project_Status_Complete_Smartsheet_Sent, updatedProject.Project_Setup_Status__c,'Project_Setup_Status__c is not set correctly');    
    } 
}