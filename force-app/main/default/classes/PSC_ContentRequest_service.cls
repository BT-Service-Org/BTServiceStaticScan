public with sharing class PSC_ContentRequest_service {
    @AuraEnabled(Cacheable=true)
    public static Content_Requests__c getContentData(String name) {
        try{
        List<Content_Requests__c> lstContentreq = [SELECT Id, Name, Description__c, Status__c, Category__c, Product__r.Name, Industry__r.Name,Target_Audience__r.Name,Assignee__r.Name, Community_Portal_URL__c,Owner.FirstName, Owner.LastName,CreatedDate FROM Content_Requests__c WHERE URLName__c=:name];
        if(!lstContentreq.isEmpty()){
            return lstContentreq[0];
        }
        return null;
    }
    catch(Exception e){
         throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
    }
    }
}