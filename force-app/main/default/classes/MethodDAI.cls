public interface MethodDAI {
    Method__c getMethodByMethodId(String methodId);
    Method__c[] getMethodListByMethodIds(Set<Id> methodIds);
}