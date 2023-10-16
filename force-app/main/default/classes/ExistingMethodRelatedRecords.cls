public with sharing class ExistingMethodRelatedRecords {
    @AuraEnabled(cacheable=true)
    //Method to retrive the existing related records for the Method
    public static List <sobject> getRecordsList (String recordId, String objectApiName){
        if(objectApiName == 'Templates__c'){
            return [select Method_Version_Description__c, Link__c, Type__c from Templates__c  where Method__c= :recordId WITH SECURITY_ENFORCED];
        }else if( objectApiName == 'Method_by_Deliverables__c') {
            return [select Role__c,Role__r.Name, Deliverable__c,Deliverable__r.Name from Method_by_Deliverables__c  where Method__c= :recordId WITH SECURITY_ENFORCED];
        }else{
            return [select LinkedEntityId,ContentDocumentId, ContentDocument.Title from ContentDocumentLink  where LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        }
        
    }
    @AuraEnabled
    public static string deleteSelectedRecord(Id deleteIdRecord, String objectApiName)
    {
        if(objectApiName == 'Templates__c')
        {
            List <Templates__c> tempId= [SELECT Id FROM Templates__c WHERE Id = :deleteIdRecord WITH SECURITY_ENFORCED];
            //system.debug('Inside the controller tempId'+tempId);
            Database.delete(tempId,true);
            return 'success';
        }
        else if(objectApiName == 'Method_by_Deliverables__c')
        {
            List <Method_by_Deliverables__c> methodByDelId= [SELECT Id FROM Method_by_Deliverables__c WHERE Id = :deleteIdRecord WITH SECURITY_ENFORCED];
            //system.debug('Inside the controller methodByDelId'+methodByDelId);
            Database.delete(methodbydelId,true);
            return 'success';
        }
        else 
        {
            List <ContentDocumentLink> conDocLinkId= [SELECT Id FROM ContentDocumentLink WHERE Id = :deleteIdRecord WITH SECURITY_ENFORCED];
            //system.debug('Inside the controller conDocLinkId'+conDocLinkId);
            Database.delete(conDocLinkId,true);
            return 'success';
        } 
    }
}