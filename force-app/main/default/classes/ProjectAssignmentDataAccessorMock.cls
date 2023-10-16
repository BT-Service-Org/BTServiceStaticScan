public with sharing class ProjectAssignmentDataAccessorMock implements ProjectAssignmentDAI {
    public Project_Assignment__c[] projectAssignments = new List<Project_Assignment__c>();

    public Project_Assignment__c[] getProjectAssignmentsByProjectId(Set<Id> projectId) {
        return projectAssignments;
    }

    public List<Project_Assignment__c> getProjectAssignmentsForUsers(Set<Id> userIds) {
        return projectAssignments;
    }

    public List<Project_Assignment__c> getProjectAssignmentsById(Set<Id> assignmentIds) {
        return projectAssignments;
    }
}