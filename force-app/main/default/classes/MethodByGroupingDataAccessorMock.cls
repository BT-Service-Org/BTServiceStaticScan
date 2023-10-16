public with sharing class MethodByGroupingDataAccessorMock implements MethodByGroupingDAI {
    public Method_by_Grouping__c[] methodByGrouping = new List<Method_by_Grouping__c>();

    public Method_by_Grouping__c[] getMethodByGroupingByMethodId(Set<Id> methodId) {
        return methodByGrouping;
    }
       
}