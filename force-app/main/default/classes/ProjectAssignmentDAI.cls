public interface ProjectAssignmentDAI {
    Project_Assignment__c[] getProjectAssignmentsByProjectId(Set<Id> projectId);
    List<Project_Assignment__c> getProjectAssignmentsForUsers(Set<Id> userIds);
    List<Project_Assignment__c> getProjectAssignmentsById(Set<Id> assignmentIds);
}