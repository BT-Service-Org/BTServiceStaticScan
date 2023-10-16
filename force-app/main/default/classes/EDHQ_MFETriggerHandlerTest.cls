/**
Class Name : EDHQ_MFETriggerHandlerTest
@description    : EDHQ_MethodForEngagementTriggerHandler Test class to take the code coverage and validate unit tests.
Created Date	: 6 Sept, 2023
*/

@isTest
public class EDHQ_MFETriggerHandlerTest {
    @TestSetup
    static void setUpData() {
        ProjectMethodTestDataFactory.createBaseData();
    }
    
    @IsTest
    static void testPublishPlatformEvent() {
        
        List<Methods__c> mfeList = [SELECT Id, PSA_Project__c, Method__c, LastModifiedById, Assigned_Resource__c, Completion_Status__c, 
                                    Actual_Start_Date__c, Actual_End_Date__c, Method_in_SOW__c, Deliverable_By__c, End_Date__c, Start_Date__c FROM Methods__c];
        
        
        EDHQ_MethodForEngagementTriggerHandler.publishPlatformEvent(mfeList, new Map<Id, Methods__c>(mfeList));

    }

    @IsTest
    static void testCheckToGeneratePlatformEvent() {        
        

        Methods__c newmfe = [SELECT Id, PSA_Project__c, Method__c, LastModifiedById, Assigned_Resource__c, Completion_Status__c, 
                            Actual_Start_Date__c, Actual_End_Date__c, Method_in_SOW__c, Deliverable_By__c, End_Date__c, Start_Date__c, Smart_Sheet_Link__c FROM Methods__c LIMIT 1];
        Boolean result;
        Methods__c oldmfe = newmfe.clone();

        
        result = EDHQ_MethodForEngagementTriggerHandler.checkToGeneratePlatformEvent(newmfe, oldmfe);
        Assert.areEqual(False, result , 'Expected result not received');

        
        newmfe.Assigned_Resource__c = UserInfo.getUserId();
        update newmfe;

        result = EDHQ_MethodForEngagementTriggerHandler.checkToGeneratePlatformEvent(newmfe, oldmfe);
        Assert.areEqual(True, result , 'Expected result not received');

    }

    @IsTest
    static void testSetMapFromUserIdToEmail() {        
        
        List<User> userList = [SELECT Id FROM User Limit 2];
        List<Id> userIds = new List<Id>();
        for(User usr : userList){
            userIds.add(usr.Id);
        }
        EDHQ_MethodForEngagementTriggerHandler.setMapFromUserIdToEmail(userIds);
        Assert.areEqual(2, EDHQ_MethodForEngagementTriggerHandler.mapIdToEmail.size() , 'Expected result not received');
    }


    @IsTest
    static void testSetMapFromProjects() {        
        
        List<PSA_Project__c> projectList = [SELECT Id FROM PSA_Project__c];
        List<Id> projectIds = new List<Id>();
        for(PSA_Project__c proj : projectList){
            projectIds.add(proj.Id);
        }

        EDHQ_MethodForEngagementTriggerHandler.setMapFromProjects(projectIds);
        Assert.areNotEqual(0, EDHQ_MethodForEngagementTriggerHandler.mapProjetIdToSheetId.size() , 'Expected result not received');
        Assert.areNotEqual(0, EDHQ_MethodForEngagementTriggerHandler.mapProjectIdToPmEmailId.size() , 'Expected result not received');
    }

    @IsTest
    static void testSetMapFromMethodIdtoSheet() {        
        
        List<Method__c> methodList = [SELECT id, Smart_Sheet__c FROM Method__c];
        List<Id> listMethodIds = new List<Id>();
        for(Method__c meth : methodList){
            listMethodIds.add(meth.Id);
        }

        EDHQ_MethodForEngagementTriggerHandler.setMapFromMethodIdtoSheet(listMethodIds);
        Assert.areNotEqual(0, EDHQ_MethodForEngagementTriggerHandler.mapMethodIdtoSheet.size(), 'Error');
    }

    @IsTest
    static void testCreateMfeEvent() {        
        
        Methods__c newmfeRec = [SELECT Id, PSA_Project__c, Method__c, LastModifiedById, Assigned_Resource__c, Completion_Status__c, SmartSheet_Status__c,
                            Actual_Start_Date__c, Actual_End_Date__c, Method_in_SOW__c, Deliverable_By__c, End_Date__c, Start_Date__c, Smart_Sheet_Link__c FROM Methods__c LIMIT 1];
        
        Methods__c oldmfeRec = newmfeRec.clone();

        Method_For_Engagement_Updates__e result = EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);
        Assert.areNotEqual('', result.plan_row_link__c , 'Error');
        
        newmfeRec.Method_in_SOW__c = False;
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.Deliverable_by__c = 'Customer Deliverable';
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.Completion_Status__c = 'Pending';
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.Actual_Start_Date__c = System.today() + 5;
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.Actual_End_Date__c = System.today() + 15;
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.Start_Date__c = System.today() + 3;
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        newmfeRec.End_Date__c = System.today() + 13;
        update newmfeRec;
        EDHQ_MethodForEngagementTriggerHandler.createMfeEvent(newmfeRec, oldmfeRec);

        
    }

}