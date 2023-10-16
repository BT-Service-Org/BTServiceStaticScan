public with sharing class MethodsDataAccessor implements MethodsDAI {
    public Methods__c[] getMethodsByPSAProjectId(Id psaProjectId) {
        return [
            SELECT
                Id,
                End_Date__c,
                Completion_Status__c,
                Method__r.Id,
                Method__r.Name,
                Assigned_Resource__r.Slack_User_Id__c,
                Assigned_Resource__r.CSG_Role__c,
                Assigned_Resource__r.Name,
                Assigned_Resource__r.FederationIdentifier,
                Assigned_Resource__c,
                Method__r.Tier_1__c,
                Method__r.Micro__c,
                Method__r.Small__c,
                Method__r.Medium__c,
                Method__r.Large__c,
                Method__r.Program__c,
                Method_in_SOW__c,
                OwnerId
            FROM Methods__c
            WHERE PSA_Project__c = :psaProjectId
            ORDER BY Method__r.Name
        ];
    }

    public Methods__c[] paginatedMethodsByPSAProjectId(
        Id projectId,
        Integer offset,
        Integer itemsPerPage
    ) {
        return [
            SELECT
                Id,
                End_Date__c,
                Completion_Status__c,
                Method__r.Id,
                Method__r.Name,
                Assigned_Resource__r.Slack_User_Id__c,
                Assigned_Resource__r.CSG_Role__c,
                Assigned_Resource__r.Name,
                Assigned_Resource__r.FederationIdentifier,
                Assigned_Resource__c,
                Method__r.Tier_1__c,
                Method__r.Micro__c,
                Method__r.Small__c,
                Method__r.Medium__c,
                Method__r.Large__c,
                Method__r.Program__c,
                Method_in_SOW__c,
                OwnerId
            FROM Methods__c
            WHERE PSA_Project__c = :projectId
            WITH SECURITY_ENFORCED
            ORDER BY Method__r.Name
            LIMIT :itemsPerPage
            OFFSET :offset
        ];
    }

    public String getMethodsByPSAProjectIdStringQuery(String projectId) {
        return ('SELECT Actual_Start_Date__c, Start_Date__c, End_Date__c, Completion_Status__c, Task_Title__c, ' +
        'Method__r.Id, Method__r.Name, ' +
        'Assigned_Resource__r.Slack_User_Id__c, ' +
        'Assigned_Resource__r.CSG_Role__c, ' +
        'Assigned_Resource__r.Name, ' +
        'Assigned_Resource__r.FederationIdentifier, ' +
        'Assigned_Resource__c, ' +
        'Method__r.Tier_1__c, Method__r.Micro__c, Method__r.Small__c, Method__r.Medium__c, Method__r.Large__c, Method__r.Program__c, Method_in_SOW__c, OwnerId ' +
        'FROM Methods__c ' +
        'WHERE PSA_Project__c = \'' +
        projectId +
        '\'');
    }

    public String getMethodsCountByPSAProjectIdStringQuery(String projectId) {
        return ('SELECT COUNT(Id) queryCount ' +
        'FROM Methods__c ' +
        'WHERE PSA_Project__c = \'' +
        projectId +
        '\'');
    }

    public Methods__c[] getMethodsByMethodsIds(Set<Id> methodsIds) {
        return [
            SELECT
                Name,
                Assigned_Resource__r.Slack_User_Id__c,
                Assigned_Resource__r.CSG_Role__c,
                Assigned_Resource__r.Name,
                Assigned_Resource__r.FederationIdentifier,
                Assigned_Resource__c,
                Actual_Start_Date__c,
                Start_Date__c,
                End_Date__c,
                Completion_Status__c,
                Method__r.Id,
                Method__r.Name,
                PSA_Project__r.Id,
                Smart_Sheet_Link__c,
                Method__r.Tier_1__c,
                Method__r.Micro__c,
                Method__r.Small__c,
                Method__r.Medium__c,
                Method__r.Large__c,
                Method__r.Program__c,
                Method_in_SOW__c,
                OwnerId,
                CreatedById
            FROM Methods__c
            WHERE Id IN :methodsIds
            ORDER BY Method__r.Name
        ];
    }

    public List<Methods__c> updateMethods(List<Methods__c> methodsToUpdate) {
        if (methodsToUpdate?.isEmpty() == false) {
            update methodsToUpdate;
        }
        return methodsToUpdate;
    }

    public List<Methods__c> deleteMethodFromProject(Id methodId) {
        List<Methods__c> methodsToDelete = [SELECT Id, Name FROM Methods__c WHERE Id = :methodId];

        if (methodsToDelete.isEmpty() == false) {
            delete methodsToDelete;
        }

        return methodsToDelete;
    }

    public List<Methods__c> addMethodsForProject(List<Methods__c> methods) {
        if (methods?.isEmpty() == false) {
            insert methods;
        }

        return methods;
    }

    public List<Method_Question_Answers__c> addMethodQuestionAnswers(List<Method_Question_Answers__c> methodQuestionAnswers) {
        if (methodQuestionAnswers?.isEmpty() == false) {
            insert methodQuestionAnswers;
        }
        return methodQuestionAnswers;
    }

    public List<Methods__c> getMethodsStatus(Set<Id> methodsIds) {
        return [
            SELECT Id, Name, Completion_Status__c, Start_Date__c, Method__c, Method__r.Id
            FROM Methods__c
            WHERE Id IN :methodsIds
        ];
    }

    public List<Slack.Option> getMethodsOptionsByProjectId(Id projectId) {
        List<Methods__c> methods = new MethodsDataAccessor().getMethodsByPSAProjectId(projectId);

        List<Slack.Option> methodsOptions = new List<Slack.Option>();
        if (methods != null) {
            for (Methods__c method : methods) {
                Slack.Option option = new Slack.Option(method.Method__r.Name, method.Id);
                methodsOptions.add(option);
            }
        }
        return methodsOptions;
    }

    public List<Methods__c> getMethodinSOWandDeliverable(Id methodId) {
        return [
            SELECT Id, Name, Method_in_SOW__c, Deliverable_by__c
            FROM Methods__c
            WHERE Id = :methodId
        ];
    }

    public List<Method_Question__c> getMethodQuestionsByMethodId(Id methodId){
        return [
            SELECT Id, SPSM_Question__r.Question__c, SPSM_Question__r.Question_Help_Text__c, Mandatory__c
            FROM Method_Question__c
            WHERE Method__c = :methodId
            ORDER BY Question_Order__c
        ];
    }

    public List<Method_Question__c> getMethodTextQuestionsByMethodId(Id methodId){
        return [
            SELECT Id, SPSM_Question__r.Id, SPSM_Question__r.Question__c, SPSM_Question__r.Question_Help_Text__c, Mandatory__c
            FROM Method_Question__c
            WHERE Method__c = :methodId AND SPSM_Question__r.RecordType.Name = : 'Text Field Question'
            ORDER BY Question_Order__c
            LIMIT 5
        ];
    }

    public List<Method_Question__c> getMethodDropdownQuestionsByMethodId(Id methodId){
        return [
            SELECT Id, SPSM_Question__r.Id, SPSM_Question__r.Question__c, SPSM_Question__r.Question_Help_Text__c, Mandatory__c, SPSM_Question__r.Dropdown_Answers__c
            FROM Method_Question__c
            WHERE Method__c = :methodId AND SPSM_Question__r.RecordType.Name = : 'Dropdown Question'
            ORDER BY Question_Order__c
            LIMIT 5
        ];
    }
}