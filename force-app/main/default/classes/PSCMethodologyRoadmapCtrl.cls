public with sharing class PSCMethodologyRoadmapCtrl {
    @AuraEnabled(Cacheable=true)
	public static List<Methodology_Version__c> getVersionData(){
        return [SELECT Status__c, Release_Notes__c ,Id,Release_Date__c,Major_Release_Number__c,Minor_Release_Number__c
                FROM Methodology_Version__c 
                ORDER BY Release_Date__c DESC NULLS LAST
                LIMIT 5];
    }
}