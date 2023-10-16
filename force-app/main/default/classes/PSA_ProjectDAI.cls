public interface PSA_ProjectDAI {
    PSA_Project__c[] getPSAProjectByProjectManagerUserId(Id userId);
    PSA_Project__c[] getPSAProjectByProjectId(Set<Id> projectIds);
    PSA_Project__c[] getPSAProjectByProjectId(Id projectId);
    PSA_Project__c[] getPSAProjectAndOpportunityByProjectId(Set<Id> projectIds);
    List<Slack.Option> getPSAProjectPicklistOptions(String fieldName);
    PSA_Project__c updateProjectFields(Id projectId, Map<String, Object> formData);
    List<PSA_Project__c> updateProjects(List<PSA_Project__c> projectsToUpdate);
    PSA_Project__c[] getProjectsAndMethodsFromProjectIds(Set<Id> projectIds, Id methodOwnerId);
    String getProjectsAndMethodsFromProjectIdsStringQuery(Set<Id> projectIds,Id methodOwnerId);
    String getProjectsAndMethodsCountFromProjectIdsStringQuery(Set<Id> projectIds);
    List<String> getPSAProjectTargetedCloudsUsed(String projectId);
}