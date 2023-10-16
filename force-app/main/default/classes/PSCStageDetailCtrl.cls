public with sharing class PSCStageDetailCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<Stage__c> getStageDetail(List<String> key,Integer maxNoOfResult) {
        List<Stage__c> stageList = [SELECT Id,Purpose__c,Description__c,Name,
                                        (SELECT Id ,Method__r.Method_Number__c
                                        FROM Method_With_Stages__r)
                                    FROM Stage__c
                                    WHERE Name IN: key
                                    LIMIT :maxNoOfResult];

        return stageList;
        // return [SELECT Id,Stage__r.Name,Stage__r.,Stage__r.Purpose__c,Method__r.Method_Number__c
        //         FROM Method_with_Stage__c
        //         WHERE Stage__r.Name IN: key];
    }
}