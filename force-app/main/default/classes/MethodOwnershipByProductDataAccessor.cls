public with sharing class MethodOwnershipByProductDataAccessor implements MethodOwnershipByProductDAI {
    public Method_Ownership_by_Product__c[] getMethodOwnershipByProductByMethodId(Set<Id> methodId) {
        return [
            SELECT Id, Role__r.Name
            FROM Method_Ownership_by_Product__c
            WHERE Method__c IN :methodId
            WITH SECURITY_ENFORCED
        ];
    }
}