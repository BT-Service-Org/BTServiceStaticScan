public with sharing class PSCProductOfferingParentCtrl {
    @AuraEnabled(cacheable=true)
    public static Product_Custom__c getProductStages(String product){
        return [SELECT Id,
                    (SELECT Id,Description__c,Name,StageNumber__c,MandatoryStage__c,StageDuration__c,Playbook_Stage__r.Name
                    FROM Stages__r
                    ORDER BY StageNumber__c ASC)
                FROM Product_Custom__c
                WHERE Name = :product
                LIMIT 1];
    }
}