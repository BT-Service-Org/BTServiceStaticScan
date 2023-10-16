public with sharing class MethodBySpecialistCloudDataAccessor implements MethodBySpecialistCloudDAI {
    public Method_by_Specialist_Cloud__c[] getMethodBySpecialistCloudByMethodId(Set<Id> methodId) {
        return [
            SELECT Id, Specialist_Cloud__r.Name
            FROM Method_by_Specialist_Cloud__c
            WHERE Method__c IN :methodId
            WITH SECURITY_ENFORCED
        ];
    }
}