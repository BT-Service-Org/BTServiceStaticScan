@isTest
public with sharing class ProjectAssignmentDataAccessorTest {
    @isTest
    private static void getProjectAssignments_givenUserIds_shouldReturnProjectAssigns() {
        ProjectAssignmentDataAccessorMock assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType)
        );
        assignmentDaMock.projectAssignments.add(mockAssignment);
        

        Test.startTest();
        List<Project_Assignment__c> returnedAssignments = new ProjectAssignmentDataAccessor()
            .getProjectAssignmentsForUsers(new Set<Id>{ MockSObjectBuilder.getMockId(User.SObjectType) });
        List<Project_Assignment__c> returnedMockAssignments = assignmentDaMock.getProjectAssignmentsForUsers(new Set<Id>{ MockSObjectBuilder.getMockId(User.SObjectType) });
        Test.stopTest();

        System.assertEquals(1, returnedMockAssignments.size(), 'should return one assignment');
        System.assertEquals(
            mockAssignment.Id,
            returnedMockAssignments[0].Id,
            'should return correct assignment'
        );
    }

    @isTest
    private static void getProjectAssignments_givenProjectIds_shouldReturnProjectAssigns() {
        ProjectAssignmentDataAccessorMock assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType)
        );
        assignmentDaMock.projectAssignments.add(mockAssignment);
        

        Test.startTest();
        List<Project_Assignment__c> returnedAssignments = new ProjectAssignmentDataAccessor()
            .getProjectAssignmentsByProjectId(new Set<Id>{ MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType) });
        List<Project_Assignment__c> returnedMockAssignments = assignmentDaMock.getProjectAssignmentsByProjectId(new Set<Id>{ MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType) });
        Test.stopTest();

        System.assertEquals(1, returnedMockAssignments.size(), 'should return one assignment');
        System.assertEquals(
            mockAssignment.Id,
            returnedMockAssignments[0].Id,
            'should return correct assignment'
        );
    }

    @isTest
    private static void getProjectAssignments_givenProjectAssignmentsIds_shouldReturnProjectAssigns() {
        ProjectAssignmentDataAccessorMock assignmentDaMock = new ProjectAssignmentDataAccessorMock();
        Project_Assignment__c mockAssignment = new Project_Assignment__c(
            Id = MockSObjectBuilder.getMockId(Project_Assignment__c.SObjectType)
        );
        assignmentDaMock.projectAssignments.add(mockAssignment);
        

        Test.startTest();
        List<Project_Assignment__c> returnedAssignments = new ProjectAssignmentDataAccessor()
            .getProjectAssignmentsById(new Set<Id>{ mockAssignment.Id });
        List<Project_Assignment__c> returnedMockAssignments = assignmentDaMock.getProjectAssignmentsById(new Set<Id>{ mockAssignment.Id });
        Test.stopTest();

        System.assertEquals(1, returnedMockAssignments.size(), 'should return one assignment');
        System.assertEquals(
            mockAssignment.Id,
            returnedMockAssignments[0].Id,
            'should return correct assignment'
        );
    }
}