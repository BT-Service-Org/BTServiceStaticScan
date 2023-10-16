/*
*********************************************************
Apex Class Name    : EDHQ_MethodForEngagementTriggerHandler
Created Date       : June 23, 2023
@description       : This is class is used to publish Platform Events 
                     for Method for engagement
@author            : Ashwani Lingwal
Modification Log:
Ver   Date         Author                       Modification
1.0   23-05-2023   Ashwani Lingwal              Initial Version
*********************************************************
*/
public with sharing class EDHQ_MethodForEngagementTriggerHandler {

    public static String integrationUser = [Select Value__c from Methodology_Config__mdt where label='MulesoftIntegrationUserId'][0].Value__c;
    public static Map<Id,String> mapIdToEmail = new Map<Id,String>();
    public static Map<Id,String> mapProjetIdToSheetId = new Map<Id,String>();
    public static Map<Id,String> mapProjectIdToPmEmailId  = new Map<Id,String>();
    public static Map<Id,String> mapMethodIdtoSheet = new Map<Id,String>();

    public static void publishPlatformEvent(List<Methods__c> newMethodsList, Map<Id, Methods__c> oldMethodsMap)
    {
        List<Method_For_Engagement_Updates__e> eventsListToFire = new List<Method_For_Engagement_Updates__e>();
        List<Methods__c> mfeToPublish = new List<Methods__c>();
        List<Id> listUserIds = new List<Id>();
        List<Id> listProjectIds = new List<Id>();
        List<Id> listMethodIds = new List<Id>();

        for(Methods__c methodRec:newMethodsList)
        {
            listUserIds.add(methodRec.LastModifiedById);
            listProjectIds.add(methodRec.PSA_Project__c);
            listMethodIds.add(methodRec.Method__c);
        }

        setMapFromUserIdToEmail(listUserIds);
        setMapFromProjects(listProjectIds);
        setMapFromMethodIdtoSheet(listMethodIds);

        for(Methods__c methodRec:newMethodsList)
        {
            if(checkToGeneratePlatformEvent(methodRec,oldMethodsMap.get(methodRec.Id)))
            {
                mfeToPublish.add(methodRec);
            }
        }

        if(mfeToPublish!=null)
        {    
            for(Methods__c mfeRec:mfeToPublish){
                Method_For_Engagement_Updates__e event = createMfeEvent(mfeRec,oldMethodsMap.get(mfeRec.Id));
                eventsListToFire.add(event);
            }
            if (eventsListToFire.size() > 0){
                EventBus.publish(eventsListToFire);
            }
        }
    }

    public static Boolean checkToGeneratePlatformEvent(Methods__c newMfe, Methods__c oldMfe)
    {
        String methodMapping = mapMethodIdtoSheet.get(newMfe.Method__c);

        if ((newMfe.Assigned_Resource__c != oldMfe.Assigned_Resource__c ||
        newMfe.Completion_Status__c != oldMfe.Completion_Status__c ||
        newMfe.Actual_Start_Date__c != oldMfe.Actual_Start_Date__c ||
        newMfe.Actual_End_Date__c != oldMfe.Actual_End_Date__c ||
        newMfe.Method_in_SOW__c != oldMfe.Method_in_SOW__c ||
        newMfe.Deliverable_By__c != oldMfe.Deliverable_By__c ||
        newMfe.End_Date__c != oldMfe.End_Date__c ||
        newMfe.Start_Date__c != oldMfe.Start_Date__c) 
        && newMfe.LastModifiedById != Id.valueOf(integrationUser) && 
        (methodMapping != null && methodMapping != 'None')&&
        newMfe.SmartSheet_Status__c!=null
        ){
            return true;
        } else{
            return false;
        }
    }

    public static void setMapFromUserIdToEmail(List<Id> listUserIds){
        List<User> userList = new List<User>([Select Id, email
                                              from User
                                              where id IN:listUserIds]);
        for (User userRec : userList){
            mapIdToEmail.put(userRec.Id, userRec.email);
        }
    }

    public static void setMapFromProjects(List<Id> listProjectIds){
        List<PSA_Project__c> projectList = new List<PSA_Project__c>([Select id, Smartsheet_ID__c, ProjectManagerUser__r.Email
                                                                     from PSA_Project__c
                                                                     where id IN:listProjectIds]);
        for (PSA_Project__c projectRec : projectList){
            mapProjetIdToSheetId.put(projectRec.Id, String.valueOf(projectRec.Smartsheet_ID__c));
            mapProjectIdToPmEmailId.put(projectRec.Id, String.valueOf(projectRec.ProjectManagerUser__r.Email));
        }
    }

    public static void setMapFromMethodIdtoSheet(List<Id> listMethodIds){
        List<Method__c> methodList = new List<Method__c>([Select id, Smart_Sheet__c
                                                          from Method__c
                                                          where id IN:listMethodIds]);
        for (Method__c methodRec : methodList){
            mapMethodIdtoSheet.put(methodRec.Id, methodRec.Smart_Sheet__c);
        }
    }

    public static Method_For_Engagement_Updates__e createMfeEvent(Methods__c newMfeRec, Methods__c oldMfeRec){
        Method_For_Engagement_Updates__e event = new Method_For_Engagement_Updates__e();
        event.eventTime__c = String.valueof(DateTime.now().getTime());
        event.lastUpdatedBy__c = mapIdToEmail.get(newMfeRec.LastModifiedById);
        event.Id__c = newMfeRec.Id;
        event.sheet_id__c = mapProjetIdToSheetId.get(newMfeRec.PSA_Project__c);
        event.smartsheet_sync_status__c = newMfeRec.SmartSheet_Status__c;
        event.method_mapping__c = mapMethodIdtoSheet.get(newMfeRec.Method__c);
        event.psa_project_id__c = newMfeRec.PSA_Project__c;
        event.plan_row_link__c = newMfeRec.Smart_Sheet_Link__c;
        event.pm_email__c = mapProjectIdToPmEmailId.get(newMfeRec.PSA_Project__c);

        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();

        if(newMfeRec.Assigned_Resource__c != oldMfeRec.Assigned_Resource__c)
        {
            jsonGen.writeStringField('Assigned_Resource__c',String.valueOf(newMfeRec.Assigned_Resource__c)==null?'':String.valueOf(newMfeRec.Assigned_Resource__c));
        }
        if(newMfeRec.Method_in_SOW__c != oldMfeRec.Method_in_SOW__c)
        {
            jsonGen.writeStringField('Method_in_SOW__c', String.valueOf(newMfeRec.Method_in_SOW__c)==null?'':String.valueOf(newMfeRec.Method_in_SOW__c));
        }
        if(newMfeRec.Deliverable_by__c != oldMfeRec.Deliverable_by__c)
        {
            jsonGen.writeStringField('Deliverable_by__c', String.valueOf(newMfeRec.Deliverable_by__c)==null?'':String.valueOf(newMfeRec.Deliverable_by__c));
        }
        if(newMfeRec.Completion_Status__c != oldMfeRec.Completion_Status__c)
        {
            jsonGen.writeStringField('Completion_Status__c', String.valueOf(newMfeRec.Completion_Status__c)==null?'':String.valueOf(newMfeRec.Completion_Status__c));
        }  
        if(newMfeRec.Actual_Start_Date__c != oldMfeRec.Actual_Start_Date__c)
        {
            jsonGen.writeStringField('Actual_Start_Date__c', String.valueOf(newMfeRec.Actual_Start_Date__c)==null?'':String.valueOf(newMfeRec.Actual_Start_Date__c));
        }        
        if(newMfeRec.Actual_End_Date__c != oldMfeRec.Actual_End_Date__c)
        {
            jsonGen.writeStringField('Actual_End_Date__c', String.valueOf(newMfeRec.Actual_End_Date__c)==null?'':String.valueOf(newMfeRec.Actual_End_Date__c));
        }      
        if(newMfeRec.Start_Date__c != oldMfeRec.Start_Date__c)
        {
            jsonGen.writeStringField('Start_Date__c', String.valueOf(newMfeRec.Start_Date__c)==null?'':String.valueOf(newMfeRec.Start_Date__c));
        }
        if(newMfeRec.End_Date__c != oldMfeRec.End_Date__c)
        {
            jsonGen.writeStringField('End_Date__c', String.valueOf(newMfeRec.End_Date__c)==null?'':String.valueOf(newMfeRec.End_Date__c));
        }
        jsonGen.writeEndObject();

        String jsonString = jsonGen.getAsString();
        jsonString = jsonString.trim().replaceAll('\\n+', '');
        event.data__c = jsonString;
        return event;
    }

}