@isTest
public with sharing class MethodOwnershipByProductDataAccessorMock implements MethodOwnershipByProductDAI{
    public Method_Ownership_by_Product__c[] methodOwnershipByProduct = new List<Method_Ownership_by_Product__c>();

    public Method_Ownership_by_Product__c[] getMethodOwnershipByProductByMethodId(Set<Id> methodId) {
        return methodOwnershipByProduct;
    }
}