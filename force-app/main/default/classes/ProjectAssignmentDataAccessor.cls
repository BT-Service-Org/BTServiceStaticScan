public with sharing class ProjectAssignmentDataAccessor implements ProjectAssignmentDAI {
    public List<Project_Assignment__c> getProjectAssignmentsForUsers(Set<Id> userIds) {
        return [
            SELECT
                Id,
                Name,
                Resource__c,
                PSA_Project__c,
                Project_Role__c,
                Start_Date__c,
                End_Date__c
            FROM Project_Assignment__c
            WHERE Resource__r.User_Record__c IN :userIds AND End_Date__c >= TODAY
            WITH SECURITY_ENFORCED
        ];
    }

    public Project_Assignment__c[] getProjectAssignmentsByProjectId(Set<Id> projectId) {
        return [
            SELECT Id, Start_Date__c, Project_Role__c, Resource__c, Resource__r.User_Record__c, Resource__r.User_Record__r.CSG_Role__c, Resource__r.FirstName, Resource__r.LastName, Resource_Name__c, PSA_Project__c, PSA_Project__r.Name, PSA_Project__r.Org62_Id__c, PSA_Project__r.SmartSheet_Link__c, End_Date__c, Project_Name__c
            FROM Project_Assignment__c
            WHERE PSA_Project__c IN :projectId AND End_Date__c >= TODAY
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Project_Assignment__c> getProjectAssignmentsById(Set<Id> assignmentIds) {
        return [
            SELECT
                Id,
                Project_Role__c,
                Resource__c,
                PSA_Project__c,
                Start_Date__c,
                End_Date__c,
                Project_Name__c
            FROM Project_Assignment__c
            WHERE Id IN :assignmentIds
            WITH SECURITY_ENFORCED
        ];
    }
}