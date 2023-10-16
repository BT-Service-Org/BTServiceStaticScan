public class EDHQ_BT_RefreshSmartsheetController {
    
    public class InputVariables{
        @InvocableVariable 
        public List<String> projectId;
    }

	@InvocableMethod
    public static void refreshSmartSheet(List<InputVariables> inputVariable) {
        List<PSA_Project__c> projList = new List<PSA_Project__c>([SELECT ProjectManagerUser__c,Id,Project_Setup_Status__c,SmartSheet_Link__c,Smartsheet_ID__c,name,Smartsheet_Creation_Error__c,Engagement_Size__c,Offering__c,Org62_Id__c from PSA_Project__c where id IN: inputVariable.get(0).projectId]);
        Map<Id, PSA_Project__c> oldProjectsMap = new Map<Id, PSA_Project__c>();
        EDHQ_PSAProjectTriggerHandler.publishPlatformEvent(projList,oldProjectsMap,'RESET');
        updateProject(projList);
    }
    public static void updateProject(List<PSA_Project__c> projList)
    {
        projList[0].Smartsheet_Creation_Error__c = '';
        projList[0].Project_Setup_Status__c = MethodologyConstants.PROJECT_STATUS_STAGE2;
        Database.update(projList,false,AccessLevel.SYSTEM_MODE);
    }
}