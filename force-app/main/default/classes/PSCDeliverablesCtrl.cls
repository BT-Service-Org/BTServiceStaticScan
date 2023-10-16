public with sharing class PSCDeliverablesCtrl {
   
    @AuraEnabled(Cacheable=true)
    public static List<Deliverables__c> getDeliverablesList(String methodId) {
        return new List<Deliverables__c>([SELECT Id, Name FROM Deliverables__c 
                                        WHERE Id IN (SELECT Deliverable__c FROM Method_by_Deliverables__c WHERE Method__c = :methodId)]);
    }
}