public with sharing class MTH_MethodDetailsModalHandler {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MethodByGroupingDAI methodByGroupingDA = new MethodByGroupingDataAccessor();
    @testVisible
    private static MethodOwnershipByProductDAI methodOwnershipByProductDA = new MethodOwnershipByProductDataAccessor();
    @testVisible
    private static MethodBySpecialistCloudDAI methodBySpecialistCloudDA = new MethodBySpecialistCloudDataAccessor();

    public static Slack.ModalView openModal(Id methodsId, String viewType) {
        Slack.ViewReference viewReference = Slack.View.mth_method_details_modal.get();
        Boolean isAssignedToProject = false;
        Methods__c[] methods = methodsDA.getMethodsByMethodsIds(new Set<Id>{ methodsId });
        Map<String, Object> methodsMap = createMethodsMap(methods[0]);
        viewReference.setParameter('methods', methodsMap);
        Method__c method = methodDA.getMethodByMethodId(methods[0].Method__c);
        Map<String, String> methodMap = createMethodMap(method);

        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();

        if (String.isNotBlank(methods[0].PSA_Project__r.Id)) {
            isAssignedToProject = true;
            Map<String, String> projectMap = createProjectMap(methods[0].PSA_Project__r.Id, methodMap, settings);
            viewReference.setParameter('project', projectMap);
        }

        viewReference.setParameter('method', methodMap);
        viewReference.setParameter('servicesOrgUrl', settings.Services_Org_URL__c);
        viewReference.setParameter('viewType', viewType);
        viewReference.setParameter('isAssignedToProject', isAssignedToProject);

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    private static Map<String, String> createProjectMap(Id projectId, Map<String, String> methodMap, Methodologies_Slack_App_Settings__c settings) {
        PSA_Project__c[] projects = psaProjectDA.getPSAProjectByProjectId(new Set<Id>{ projectId });
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Id', projects[0].Id);
        projectMap.put('Name', projects[0].Name);
        projectMap.put('url', MTH_ProjectUtils.getProjectUrl(projects[0], settings));
        String engagementSize = projects[0].Engagement_Size__c + '__c';
        projectMap.put('MethodEngagementSize', (String) methodMap.get(engagementSize));
        return projectMap;
    }

    private static Map<String, String> createMethodMap(Method__c method) {
        Map<String, String> methodMap = new Map<String, String>();
        methodMap.put('Id', method.Id);
        methodMap.put('Name', method.Name);
        methodMap.put('Method_Number__c', String.valueOf(method.Method_Number__c));
        methodMap.put('Waterfall__c', convertBooleanToYesOrNo(method.Waterfall__c));
        methodMap.put('Agile__c', convertBooleanToYesOrNo(method.Agile__c));
        methodMap.put('Large__c', method.Large__c);
        methodMap.put('Medium__c', method.Medium__c);
        methodMap.put('Small__c', method.Small__c);
        methodMap.put('Micro__c', method.Micro__c);
        methodMap.put('Program__c', method.Program__c);
        methodMap.put('Tier_1__c', method.Tier_1__c);
        methodMap.put('Grouping', getGroupingString(method.Id));
        methodMap.put('Responsible', getResponsibleString(method.Id));
        methodMap.put('ApplicableTo', getApplicableToString(method.Id));
        return methodMap;
    }

    private static Map<String, Object> createMethodsMap(Methods__c methods) {
        Map<String, Object> methodsMap = new Map<String, Object>();
        methodsMap.put('Id', String.valueOf(methods.Id));
        if (String.isNotBlank(methods.Assigned_Resource__r.Slack_User_Id__c)){
            methodsMap.put('AssignedResource', '*(<@' + methods.Assigned_Resource__r.Slack_User_Id__c + '>)*');
        } else {
            methodsMap.put('AssignedResource', ':warning: No assignment set');
        }
        methodsMap.put('AssignedResourceRole', methods.Assigned_Resource__r.CSG_Role__c);
        Boolean isComplete = false;
        if (methods.Completion_Status__c == 'Complete'){
            isComplete = true;
        } else {
            methodsMap.put('Start_Date__c', getEmojiBasedOnStartDate(methods.Start_Date__c, methods.Actual_Start_Date__c));
        }
        methodsMap.put('isComplete', isComplete);
        methodsMap.put('isNotComplete', !isComplete);
        return methodsMap;
    }

    private static String getGroupingString(Id methodId) {
        Method_by_Grouping__c[] groupings = methodByGroupingDA.getMethodByGroupingByMethodId(new Set<Id>{methodId});
        Set<String> groupingNames = new Set<String>();
        for (Method_by_Grouping__c grouping : groupings) {
            if (String.isNotBlank(grouping.Grouping__r.Name)) {
                groupingNames.add(grouping.Grouping__r.Name);
            }
        }
        String groupingString = String.join((Iterable<String>)groupingNames, ', ');
        return groupingString;
    }

    private static String getResponsibleString(Id methodId) {
        Method_Ownership_by_Product__c[] ownerships = methodOwnershipByProductDA.getMethodOwnershipByProductByMethodId(new Set<Id>{methodId});
        Set<String> responsibleRoles = new Set<String>();
        for (Method_Ownership_by_Product__c ownership : ownerships) {
            if (String.isNotBlank(ownership.Role__r.Name)) {
                responsibleRoles.add(ownership.Role__r.Name);
            }
        }
        String responsibleString = String.join((Iterable<String>)responsibleRoles, ', ');
        return responsibleString;
    }

    private static String getApplicableToString(Id methodId) {
        Method_by_Specialist_Cloud__c[] specialistClouds = methodBySpecialistCloudDA.getMethodBySpecialistCloudByMethodId(new Set<Id>{methodId});
        Set<String> applicableToSet = new Set<String>();
        for (Method_by_Specialist_Cloud__c specialistCloud : specialistClouds) {
            if (String.isNotBlank(specialistCloud.Specialist_Cloud__r.Name)) {
                applicableToSet.add(specialistCloud.Specialist_Cloud__r.Name);
            }
        }
        String applicableToString = String.join((Iterable<String>)applicableToSet, ', ');
        return applicableToString;
    }
    
    private static String convertBooleanToYesOrNo(Boolean methodField) {
        if (methodField) {
            return 'Yes';
        } else {
            return 'No';
        }
    }

    private static String getEmojiBasedOnStartDate(Date methodsStartDate, Date actualStartDate) {
        if (methodsStartDate == null) {
            return ':warning: _No start date set_';
        }

        if (methodsStartDate.daysBetween(Date.today()) < 0 || actualStartDate?.daysBetween(Date.today()) >= 0) {
            return ':large_green_circle: ' + methodsStartDate.format();
        } else {
            return ':red_circle: ' + methodsStartDate.format();
        }
    }
}