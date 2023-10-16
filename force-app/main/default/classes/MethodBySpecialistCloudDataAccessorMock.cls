@isTest
public with sharing class MethodBySpecialistCloudDataAccessorMock implements MethodBySpecialistCloudDAI {
    public Method_by_Specialist_Cloud__c[] methodBySpecialistCloud = new List<Method_by_Specialist_Cloud__c>();

    public Method_by_Specialist_Cloud__c[] getMethodBySpecialistCloudByMethodId(Set<Id> methodId) {
        return methodBySpecialistCloud;
    }
}