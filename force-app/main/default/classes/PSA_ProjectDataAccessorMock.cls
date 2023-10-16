@isTest
public with sharing class PSA_ProjectDataAccessorMock implements PSA_ProjectDAI {
    public PSA_Project__c[] projects = new List<PSA_Project__c>{};
    public PSA_Project__c project = new PSA_Project__c();
    public List<Slack.Option> projectFieldOptions = new List<Slack.Option>();
    public List<PSA_Project__c> updatedProjects = new List<PSA_Project__c>{};

    public PSA_Project__c[] getPSAProjectByProjectManagerUserId(Id userId) {
        return projects;
    }

    public PSA_Project__c[] getPSAProjectByProjectId(Set<Id> projectIds) {
        return projects;
    }

    public PSA_Project__c[] getPSAProjectByProjectId(Id projectIds) {
        return projects;
    }

    public PSA_Project__c[] getPSAProjectAndOpportunityByProjectId(Set<Id> projectIds) {
        return projects;
    }

    public List<Slack.Option> getPSAProjectPicklistOptions(String fieldName) {
        return projectFieldOptions;
    }

    public PSA_Project__c updateProjectFields(Id projectId, Map<String, Object> formData) {
        return project;
    }

    public List<PSA_Project__c> updateProjects(List<PSA_Project__c> projectsToUpdate) {
        updatedProjects.addAll(projectsToUpdate);
        return updatedProjects;
    }

    public PSA_Project__c[] getProjectsAndMethodsFromProjectIds(Set<Id> projectIds, Id methodOwnerId){
        return projects;
    }

    public String getProjectsAndMethodsFromProjectIdsStringQuery(
        Set<Id> projectIds,
        Id methodOwnerId
    ) {
        List<String> projectIdsStr = (List<String>)new List<Id>(projectIds);
        String projectIdsCsv = '\'' + String.join(projectIdsStr, '\',\'') + '\'';
        
        return 'SELECT ' +
                'Id, ' +
                'Name, ' +
                'Start_Date__c, ' +
                'End_Date__c, ' +
                'Project_ID__c, ' +
                'Engagement_Size__c, ' +
                'Engagement_Type__c, ' +
                'Targeted_Clouds_Used__c, ' +
                'Opportunity__r.Targeted_Clouds__c, ' +
                'Preferred_Methodology__c, ' +
                '( ' +
                '    SELECT Id, Method__r.Name, Method__r.Method_Headline__c, End_Date__c, OwnerId ' +
                '    FROM Method_for_Projects__r ' +
                '    WHERE OwnerId = \'' + methodOwnerId +'\'' +
                ') ' +
                'Other_Preferred_Methodology__c, ' +
                'Project_Management_Tool__c, ' +
                'Other_Project_Management_Tool__c, ' +
                'Work_Management_Tool__c, ' +
                'Other_Work_Management_Tool__c, ' +
                'CICD_Tool__c, ' +
                'Other_CICD_Tool__c, ' +
                'Automated_Testing_Tool__c, ' +
                'Other_Automated_Testing_Tool__c, ' +
                'DAF_Review_Options__c ' +
            'FROM PSA_Project__c ' +
            'WHERE Id IN (' + projectIds + ') AND (NOT Name LIKE \'Z-%\') ' +
            'WITH SECURITY_ENFORCED';
    }

    public String getProjectsAndMethodsCountFromProjectIdsStringQuery(Set<Id> projectIds) {
        List<String> projectIdsStr = (List<String>)new List<Id>(projectIds);
        String projectIdsCsv = '\'' + String.join(projectIdsStr, '\',\'') + '\'';
        return ('SELECT COUNT(Id) queryCount' +
            'FROM PSA_Project__c ' +
            'WHERE Id IN (' + projectIdsCsv + ') AND (NOT Name LIKE \'Z-%\') ' +
            'WITH SECURITY_ENFORCED');
    }

    public List<String> getPSAProjectTargetedCloudsUsed(String projectId){
        return new List<String>();
    }
}