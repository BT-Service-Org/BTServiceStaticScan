public interface MethodsDAI {
    Methods__c[] getMethodsByPSAProjectId(Id psaProjectId);

    Methods__c[] paginatedMethodsByPSAProjectId(Id projectId, Integer offset, Integer itemsPerPage);

    String getMethodsByPSAProjectIdStringQuery(String projectId);

    String getMethodsCountByPSAProjectIdStringQuery(String projectId);

    Methods__c[] getMethodsByMethodsIds(Set<Id> methodsIds);

    List<Methods__c> updateMethods(List<Methods__c> methodsToUpdate);

    List<Methods__c> deleteMethodFromProject(Id methodId);

    List<Methods__c> addMethodsForProject(List<Methods__c> methods);

    List<Methods__c> getMethodsStatus(Set<Id> methodsIds);

    List<Methods__c> getMethodinSOWandDeliverable(Id methodId);

    List<Slack.Option> getMethodsOptionsByProjectId(Id projectId);
    
    List<Method_Question_Answers__c> addMethodQuestionAnswers(List<Method_Question_Answers__c> methodQuestionAnswers);

    List<Method_Question__c> getMethodQuestionsByMethodId(Id methodId);

    List<Method_Question__c> getMethodTextQuestionsByMethodId(Id methodId);

    List<Method_Question__c> getMethodDropdownQuestionsByMethodId(Id methodId);
}