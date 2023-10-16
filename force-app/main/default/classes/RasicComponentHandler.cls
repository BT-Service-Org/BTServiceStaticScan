public with sharing class RasicComponentHandler {

    @AuraEnabled(cacheable=true)
    public static List<Activity__c> getActivityRecords(List<Id> activityIds) {
        
        List<Activity__c> activityList=new List<Activity__c>();
        
        if(activityIds != null && !activityIds.isEmpty()){
            activityList=[SELECT Id, Name, Related_Method__r.Name 
                                        FROM Activity__c WHERE Id IN :activityIds WITH SECURITY_ENFORCED];
        }
        return activityList;
    }
     //Code Change for W-12628204
    @AuraEnabled(cacheable=true)
    public static List<Method_By_Activity__c> getActivityList(String methodId) {
        List<Method_By_Activity__c> methodActivityLst = [SELECT Id, Method__r.Name, Method__r.Id, Name, Activity__c, Activity__r.Name FROM Method_By_Activity__c 
        WHERE (Method__c =:methodId)];
        return methodActivityLst;
    }

     //Code Change for W-12628204
    @AuraEnabled(cacheable=true)
    public static List<Activity_Ownership__c> activityOwnerList(String methodId){
        List<Activity_Ownership__c> actOwnerLst=new List<Activity_Ownership__c>();

        if(!String.isBlank(methodId)){
            actOwnerLst=[SELECT Id, Name, Activity__c, Activity__r.Id, Accountable__c, Consulted__c, Informed__c, Method__c, Method__r.Name, Activity__r.Name,
                                         Responsible__c, Support__c, Role__c, Role__r.Name FROM Activity_Ownership__c 
                                         WHERE Method__c =:methodId WITH SECURITY_ENFORCED];
        }
                                        return actOwnerLst;
    }

     //Code Change for W-12628204
    @AuraEnabled(cacheable=true)
    public static List<Activity__c> getActivity(String activityId) {
        List<Activity__c> activityList=[SELECT Id, Name, Related_Method__c,Related_Method__r.Name,
                                        (SELECT Id, Activity__c, Accountable__c, Consulted__c, Informed__c, 
                                         Responsible__c, Support__c, Role__c, Role__r.Name FROM Activity_Ownerships__r) 
                                        FROM Activity__c WHERE Id=:activityId WITH SECURITY_ENFORCED];
        return activityList;
    }
    //Code Change for W-12628204
    @AuraEnabled(cacheable=true)
    public static List<Activity__c> getActivityByMethod(String methodId) {
        return [SELECT Id, Name, Related_Method__c,Related_Method__r.Name 
        FROM Activity__c WHERE Related_Method__c =:methodId WITH SECURITY_ENFORCED Order by LastModifiedDate DESC LIMIT 1];
    }
    //Code Change for W-12628204
    @AuraEnabled(cacheable=true)
    public static List<Method_By_Activity__c> getMethodByActivity(String activityId, String methodId) {
        List<Method_By_Activity__c> methActLst = [ SELECT Id, Method__r.Name, Method__r.Id, Name, Activity__c, Activity__r.Name FROM Method_By_Activity__c 
        WHERE (Activity__c =:activityId AND Method__c =:methodId)
        WITH SECURITY_ENFORCED Order by LastModifiedDate DESC LIMIT 1];
        return methActLst;

    }
}