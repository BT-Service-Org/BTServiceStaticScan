@isTest
public with sharing class ProjectProductDataAccessorTest {
    @isTest
    private static void getProjectProduct_givenProjectId_shouldReturnProjectProductFields() {
        ProjectProductDataAccessorMock projectProductDAMock = new ProjectProductDataAccessorMock();
        PSA_ProjectDataAccessorMock psaProjectDAMock = new PSA_ProjectDataAccessorMock();
        
        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.getSObjectType())
        );
        psaProjectDAMock.projects.add(mockProject);

        Project_by_Product_Offerings__c mockProjectProduct = new Project_by_Product_Offerings__c(
            Id = MockSObjectBuilder.getMockId(Project_by_Product_Offerings__c.getSObjectType()),
            Project__c = mockProject.Id
        );
        projectProductDAMock.projectProducts.add(mockProjectProduct);

        Test.startTest();
        Project_by_Product_Offerings__c[] returnedProjectProducts = new ProjectProductDataAccessor()
            .getProjectProductByProjectId(new Set<Id>{mockProject.Id});
        Project_by_Product_Offerings__c[] returnedMockProjectProducts = projectProductDAMock.getProjectProductByProjectId(new Set<Id>{mockProject.Id});
        Test.stopTest();

        System.assertEquals(mockProjectProduct.Id, returnedMockProjectProducts[0].Id, 'should return correct project product id');
    }
    
}