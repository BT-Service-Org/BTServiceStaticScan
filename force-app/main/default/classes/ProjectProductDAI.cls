public interface ProjectProductDAI {
    Project_by_Product_Offerings__c[] getProjectProductByProjectId(Set<Id> projectId);
}