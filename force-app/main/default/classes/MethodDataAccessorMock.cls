@isTest
public with sharing class MethodDataAccessorMock implements MethodDAI {
    public Method__c method = new Method__c();
    public Method__c[] methods = new List<Method__c>();

    public Method__c getMethodByMethodId(String methodId) {
        return method;
    }

   public Method__c[] getMethodListByMethodIds(Set<Id> methodIds){
        return methods;
   }
}