@isTest
public with sharing class MethodsDataAccessorMock implements MethodsDAI {
    public Methods__c[] methods = new List<Methods__c>{};
    public Set<Id> deletedMethodIds = new Set<Id>();
    public List<Slack.Option> methodsOptions = new List<Slack.Option>();

    public Methods__c[] getMethodsByPSAProjectId(Id psaProjectId) {
        return methods;
    }
    public Methods__c[] getMethodsByMethodsIds(Set<Id> methodsIds) {
        return methods;
    }

    public List<Methods__c> updatedMethods = new List<Methods__c>();
    public List<Methods__c> updateMethods(List<Methods__c> methodsToUpdate) {
        updatedMethods.addAll(methodsToUpdate);
        return methodsToUpdate;
    }

    public List<Methods__c> getMethodsStatus(Set<Id> methodsIds) {
        return methods;
    }

    public List<Methods__c> addMethodsForProject(List<Methods__c> methodsToAdd) {
        for (Methods__c method: methodsToAdd) {
            methods.add(method);
        }
        return methods;
    }

    public String getMethodsCountByPSAProjectIdStringQuery(String projectId){
        return ('SELECT End_Date__c, Completion_Status__c, ' +
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

    public List<Slack.Option> getMethodsOptionsByProjectId(Id projectId) {
        return methodsOptions;
    }

    public String getMethodsByPSAProjectIdStringQuery(String projectId) {
        return ('SELECT COUNT(Id) queryCount ' +
        'FROM Methods__c ' +
        'WHERE PSA_Project__c = \'' +
        projectId +
        '\'');
    }

    public List<Methods__c> deleteMethodFromProject(Id methodId) {
        deletedMethodIds.add(methodId);
        return methods;
    }

    public Methods__c[] paginatedMethodsByPSAProjectId(Id projectId, Integer offset, Integer itemsPerPage) {
        return methods;
    }

    public List<Methods__c> getMethodinSOWandDeliverable(Id methodId) {
        return methods;
    }

    public List<Method_Question_Answers__c> methodQuestionAnswersList = new List<Method_Question_Answers__c>();
    public List<Method_Question_Answers__c> addMethodQuestionAnswers(List<Method_Question_Answers__c> methodQuestionAnswers){
        for (Method_Question_Answers__c methodQuestionAnswer: methodQuestionAnswers){
            methodQuestionAnswersList.add(methodQuestionAnswer);
        }
        return methodQuestionAnswersList;
    }

    public List<Method_Question__c> methodQuestions = new List<Method_Question__c>();
    public List<Method_Question__c> getMethodQuestionsByMethodId(Id methodId) {
        return methodQuestions;
    }

    public List<Method_Question__c> getMethodTextQuestionsByMethodId(Id methodId) {
        return methodQuestions;
    }

    public List<Method_Question__c> getMethodDropdownQuestionsByMethodId(Id methodId) {
        return methodQuestions;
    }
}