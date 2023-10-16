public with sharing class ProjectProductDataAccessorMock {
    public Project_by_Product_Offerings__c[] projectProducts = new List<Project_by_Product_Offerings__c>();

    public Project_by_Product_Offerings__c[] getProjectProductByProjectId(Set<Id> projectId) {
        return projectProducts;
    }
}