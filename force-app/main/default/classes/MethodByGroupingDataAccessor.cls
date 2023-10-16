public with sharing class MethodByGroupingDataAccessor implements MethodByGroupingDAI {
    public Method_by_Grouping__c[] getMethodByGroupingByMethodId(Set<Id> methodId) {
        return [
            SELECT Id, Method__r.Name, Grouping__r.Name
            FROM Method_by_Grouping__c
            WHERE Method__c IN :methodId
            WITH SECURITY_ENFORCED
        ];
    }
}