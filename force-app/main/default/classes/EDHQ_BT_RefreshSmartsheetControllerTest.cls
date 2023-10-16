/**
Class Name : EDHQ_BT_RefreshSmartsheetControllerTest
@description    : EDHQ_BT_RefreshSmartsheetController Test class to take the code coverage and validate unit tests.
Created Date	: 7 Sept, 2023
*/

@isTest
public class EDHQ_BT_RefreshSmartsheetControllerTest {
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }
    
    @IsTest
    static void testRefreshSmartSheet() {
        
        List<PSA_Project__c> projList = [SELECT Id, Name, Project_Setup_Status__c, ProjectManagerUser__c, SmartSheet_Link__c, Smartsheet_ID__c, Smartsheet_Creation_Error__c,
                                            Engagement_Size__c, Offering__c, Org62_Id__c FROM PSA_Project__c];
        
        List<EDHQ_BT_RefreshSmartsheetController.InputVariables> inputVars = new List<EDHQ_BT_RefreshSmartsheetController.InputVariables>();
        EDHQ_BT_RefreshSmartsheetController.InputVariables projVar = new EDHQ_BT_RefreshSmartsheetController.InputVariables();
        projVar.projectId = new List<String> { projList[0].Id};
        inputVars.add(projVar);

        EDHQ_BT_RefreshSmartsheetController.refreshSmartSheet(inputVars);
        PSA_Project__c updatedProject = [SELECT Id, Smartsheet_Creation_Error__c, Project_Setup_Status__c FROM PSA_Project__c WHERE Id = :projList[0].Id];
        Assert.areEqual(null , updatedProject.Smartsheet_Creation_Error__c, 'Expected result not received');
        Assert.areEqual(MethodologyConstants.PROJECT_STATUS_STAGE2, updatedProject.Project_Setup_Status__c, 'Expected result not received');
        
    }

}