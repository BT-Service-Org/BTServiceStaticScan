public with sharing class EDHQ_PSAProjectTriggerHandler {

    public static String integrationUser = [Select Value__c from Methodology_Config__mdt where label='MulesoftIntegrationUserId'][0].Value__c;
    public static Map<Id,String> mapIdToEmail = new Map<Id,String>();
    public static Map<Id,List<Methods__c>> mapIdToMfeList = new Map<Id,List<Methods__c>>();

    public static Map<String, String> offeringToMDTMap = new Map<String, String>();

    public static void getMethodologySmartsheetMetatdata(){
        List<Methodology_Smartsheet_Mapping__mdt> msmList = Methodology_Smartsheet_Mapping__mdt.getAll().values();
        String mapkey;
        for(Methodology_Smartsheet_Mapping__mdt m : msmList){
            mapkey = m.Offering__c + (m.Engagement_Size__c != null ? m.Engagement_Size__c : '');
            offeringToMDTMap.put(mapkey, m.DeveloperName);
        }
    }


    public static void publishPlatformEvent(List<PSA_Project__c> projects, Map<Id, PSA_Project__c> oldProjectsMap, String eventType){

        List<SmartSheets_Project_Set_up__e> eventsListToFire = new List<SmartSheets_Project_Set_up__e>();
        List<Id> pmUserIds = new List<Id>();
        List<PSA_Project__c> projectToPublish = new List<PSA_Project__c>();
        List<Id> projectIds = new List<Id>();
        List<Id> listUserIds = new List<Id>();

        for(PSA_Project__c projRec : projects)
        {
            PSA_Project__c oldProjectRec = oldProjectsMap.get(projRec.Id)== null ? new PSA_Project__c() : oldProjectsMap.get(projRec.Id);
            if(isMeetingPeTriggeringConditions(projRec,oldProjectRec)||eventType=='RESET')
            {
                if(projRec.ProjectManagerUser__c!=null)
                {
                    pmUserIds.add(projRec.ProjectManagerUser__c);
                }
                projectToPublish.add(projRec);
                projectIds.add(projRec.Id);
                listUserIds.add(projRec.ProjectManagerUser__c);
            }
        }
        if(projectToPublish!=null)
        {
            setMfeMap(projectIds);
            setMapFromUserIdToEmail(listUserIds);

            for(PSA_Project__c projectRec : projectToPublish)
            {
                SmartSheets_Project_Set_up__e event = createProjectEvent(projectRec,oldProjectsMap.get(projectRec.Id),eventType);
                eventsListToFire.add(event);
            }
            if (eventsListToFire.size() > 0){
                EventBus.publish(eventsListToFire);
            }
        }
        

    }

    public static void setMfeMap(List<Id> projectIds)
    {
        List<Methods__c> mfeList = [select id,Method_Number__c,Method_in_SOW__c, Deliverable_by__c,Method__r.Smart_Sheet__c,PSA_Project__c,SmartSheet_Status__c from Methods__c where PSA_Project__c IN:projectIds];
        for(Methods__c mfe:mfeList)
        {
            if(mapIdToMfeList.get(mfe.PSA_Project__c)==null)
            {
                List<Methods__c> mfes = new List<Methods__c>();
                mfes.add(mfe);
                mapIdToMfeList.put(mfe.PSA_Project__c,mfes);
            }
            else{
                mapIdToMfeList.get(mfe.PSA_Project__c).add(mfe);
            }
        }
    }

    public static Boolean isMeetingPeTriggeringConditions(PSA_Project__c newProjRec,PSA_Project__c oldProjRec)
    {
        if(newProjRec.Project_Setup_Status__c == MethodologyConstants.PROJECT_STATUS_STAGE2
        && newProjRec.Project_Setup_Status__c != oldProjRec.Project_Setup_Status__c
        && newProjRec.SmartSheet_Link__c == null)
        {
            return true;
        }
        else {
            return false;
        }
        
    }

    public static void setMapFromUserIdToEmail(List<Id> listUserIds)
    {
        List<User> userList = new List<User>([Select Id,email from User where id IN:listUserIds]);
        for(User userRec : userList)
        {
            mapIdToEmail.put(userRec.Id, userRec.email);
        }
    }

    public static SmartSheets_Project_Set_up__e createProjectEvent(PSA_Project__c newProject,PSA_Project__c oldProject,String eventType){
        SmartSheets_Project_Set_up__e event = new SmartSheets_Project_Set_up__e();
        event.eventType__c = eventType;
        if(eventType=='RESET')
        {
            event.project_plan_id__c = newProject.Smartsheet_ID__c;
        }
        else {
            event.project_plan_id__c = null;
        }
        event.template_workspace_id__c = getTemplateWorkspaceId(newProject.Offering__c, newProject.Engagement_Size__c);
        event.template_plan_id__c = getTemplatePlanId(newProject.Offering__c, newProject.Engagement_Size__c);
        event.psa_project_id__c  = newProject.Id;
        event.psa_project_name__c = newProject.Name;
        event.pm_email__c = mapIdToEmail.get(newProject.ProjectManagerUser__c)==null?'null':mapIdToEmail.get(newProject.ProjectManagerUser__c);
        event.org62_psa_project_id__c = newProject.Org62_Id__c;

        List<Methods__c> mfeList = mapIdToMfeList.get(newProject.Id)==null?null:mapIdToMfeList.get(newProject.Id);

        if(mfeList!=null)
        {
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartArray();
            for(Methods__c mfeRec: mfeList)
            {
                if(mfeRec.SmartSheet_Status__c != 'Added from Smartsheet')
                {
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('method_id',mfeRec.id);
                    jsonGen.writeStringField('method_number',String.valueOf(mfeRec.Method_Number__c));
                    jsonGen.writeStringField('method_in_sow',String.valueOf(mfeRec.Method_in_SOW__c));
                    jsonGen.writeStringField('method_deliverable_by',mfeRec.Deliverable_by__c==null?'':mfeRec.Deliverable_by__c);
                    jsonGen.writeStringField('method_mapping',mfeRec.Method__r.Smart_Sheet__c==null?'':mfeRec.Method__r.Smart_Sheet__c);
                    jsonGen.writeEndObject();
                }
            }     
            jsonGen.writeEndArray();  
            String selectedMethods = String.valueOf(jsonGen.getAsString()).trim().replaceAll('\\n+',' ');
            event.selected_methods__c = selectedMethods;     
        }

        return event;
    }

    public static string getTemplateWorkspaceId(String Offering, String engagementSize)
    {
        String templateId = getTemplateId(Offering, engagementSize);
        integer idx = templateId.indexOf('+');

        return templateId.substring(0, idx);
    }


    public static string getTemplatePlanId(String Offering, String engagementSize)
    {
        String templateId = getTemplateId(Offering, engagementSize);
        integer idx = templateId.indexOf('+');
        
        return templateId.substring(idx+1 , templateId.length());
    }
       

    public static string getTemplateId(String Offering, String engagementSize){
        
        getMethodologySmartsheetMetatdata();

        String returnstring;
        String offEngKey = Offering + (engagementSize != null ? engagementSize : '');

        if (Offering!= null && offeringToMDTMap.containsKey(offEngKey)) {
            String mdtLabelName = offeringToMDTMap.get(offEngKey);
    
                returnstring = Methodology_Smartsheet_Mapping__mdt.getInstance(mdtLabelName).Template_Workspace_ID__c + '+' + Methodology_Smartsheet_Mapping__mdt.getInstance(mdtLabelName).Template_Sheet_ID__c;
            
        }else{
                returnstring = Methodology_Smartsheet_Mapping__mdt.getInstance(MethodologyConstants.OFFERING_DEFAULT).Template_Workspace_ID__c + '+' + Methodology_Smartsheet_Mapping__mdt.getInstance(MethodologyConstants.OFFERING_DEFAULT).Template_Sheet_ID__c;
        }

        return returnstring;
    }

}