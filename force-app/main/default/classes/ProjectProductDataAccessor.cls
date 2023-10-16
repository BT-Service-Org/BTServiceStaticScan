public with sharing class ProjectProductDataAccessor implements ProjectProductDAI {
    public Project_by_Product_Offerings__c[] getProjectProductByProjectId(Set<Id> projectId) {
        return [
            SELECT Id, Product__r.Name
            FROM Project_by_Product_Offerings__c
            WHERE Project__c IN :projectId
            WITH SECURITY_ENFORCED
        ];
    }
}