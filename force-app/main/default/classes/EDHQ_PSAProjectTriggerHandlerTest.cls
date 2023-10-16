@isTest
public class EDHQ_PSAProjectTriggerHandlerTest {
	@TestSetup
    Static void setUpData(){
        ProjectMethodTestDataFactory.createBaseData();
    }
    static final string msg = 'Expected Results Not Received';
    @isTest
    static void testPublishPlatformEvent(){
        
        List<PSA_Project__c> psaProjectList = [SELECT Id, Name, ProjectManagerUser__c, Offering__c, Method_for_Engagement_status__c,
                                                Smartsheet_ID__c, Project_Setup_Status__c, Engagement_Size__c FROM PSA_Project__c];
        
        EDHQ_PSAProjectTriggerHandler.publishPlatformEvent(psaProjectList,new Map<Id, PSA_Project__c>(psaProjectList),'RESET');
        EDHQ_PSAProjectTriggerHandler.publishPlatformEvent(psaProjectList,new Map<Id, PSA_Project__c>(psaProjectList),'SETUP');
        
    }
    
    @isTest
    static void testSetMfeMap(){
        
        List<PSA_Project__c> projectList = [SELECT Id FROM PSA_Project__c];
        List<Id> projectIds = new List<Id>();
        for(PSA_Project__c proj : projectList){
            projectIds.add(proj.Id);
        }
        
        EDHQ_PSAProjectTriggerHandler.setMfeMap(projectIds);
        
    }
    
    @isTest
    static void testIsMeetingPeTriggeringConditions(){
        
        PSA_Project__c psaProject = [SELECT Id, Name, ProjectManagerUser__c, Offering__c, Method_for_Engagement_status__c,Smartsheet_ID__c, 
                                     Project_Setup_Status__c, Engagement_Size__c FROM PSA_Project__c];

        Boolean result;
        result = EDHQ_PSAProjectTriggerHandler.isMeetingPeTriggeringConditions(psaProject,psaProject);
        Assert.isFalse(result, msg);
        
        psaProject.Project_Setup_Status__c = MethodologyConstants.PROJECT_STATUS_STAGE2;
        psaProject.SmartSheet_Link__c = null;
        update psaProject;
        
        result = EDHQ_PSAProjectTriggerHandler.isMeetingPeTriggeringConditions(psaProject,psaProject);
        Assert.isFalse(result, msg);        
    }
    
    @isTest
    static void testSetMapFromUserIdToEmail(){
        
        List<User> userList = [Select Id,email from User LIMIT 5];
        List<Id> listUserIds = new List<Id>();
        for(User usr : userList){
            listUserIds.add(usr.Id);
        }

		EDHQ_PSAProjectTriggerHandler.setMapFromUserIdToEmail(listUserIds);
    }
    
    @isTest
    static void testCreateProjectEvent(){
        
		PSA_Project__c psaProject = [SELECT Id, Name, ProjectManagerUser__c, Offering__c, Method_for_Engagement_status__c, Smartsheet_ID__c, 
                                     Project_Setup_Status__c, Engagement_Size__c FROM PSA_Project__c];
        
		EDHQ_PSAProjectTriggerHandler.createProjectEvent(psaProject, psaProject, 'SETUP');
    }
    
    @isTest
    static void testGetTemplateWorkspaceId(){
        
		PSA_Project__c psaProject = [SELECT Id, Offering__c, Engagement_Size__c FROM PSA_Project__c];
        String result =	EDHQ_PSAProjectTriggerHandler.getTemplateWorkspaceId(psaProject.Offering__c, psaProject.Engagement_Size__c);
        Assert.areEqual('7905289660852100', result, msg);
    }
    
    @isTest
    static void testGetTemplatePlanId(){
        
		PSA_Project__c psaProject = [SELECT Id, Offering__c, Engagement_Size__c FROM PSA_Project__c];
        String result =	EDHQ_PSAProjectTriggerHandler.getTemplatePlanId(psaProject.Offering__c, psaProject.Engagement_Size__c);
        Assert.areEqual('3824084785778564', result, msg);
    }
    
    @isTest
    static void testGetTemplateId(){
        
		PSA_Project__c psaProject = [SELECT Id, Offering__c, Engagement_Size__c FROM PSA_Project__c];
        
        String result;
        result = EDHQ_PSAProjectTriggerHandler.getTemplateId(psaProject.Offering__c, psaProject.Engagement_Size__c);
        Assert.areEqual('7905289660852100+3824084785778564', result, msg);
        
        psaProject.Offering__c = 'Capsule';
        update psaProject;
        result = EDHQ_PSAProjectTriggerHandler.getTemplateId(psaProject.Offering__c, psaProject.Engagement_Size__c);
        Assert.areEqual('7905289660852100+3824084785778564', result, msg);
       
    }

}