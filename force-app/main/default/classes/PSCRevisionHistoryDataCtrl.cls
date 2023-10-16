public with sharing class PSCRevisionHistoryDataCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<Methodology_Version__c>  getMethodologyVersionData(String key) {

        return PSCRevisionHistoryDataService.getData(key);
    }
}