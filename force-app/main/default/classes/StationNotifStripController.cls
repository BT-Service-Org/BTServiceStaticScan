public with sharing class StationNotifStripController {
    @AuraEnabled(cacheable=true)
    public static Station_Content__c  getNotificationStripRecord(String stationId) {
        Station_Content__c  stationContent = [SELECT Id, Name, notif_Title__c, notif_SubTitle__c, notif_Call_to_Action_1_Title__c, notif_Call_to_Action_1_URL__c, notif_Call_to_Action_1_Image__c, notif_Call_to_Action_2_Title__c, notif_Call_to_Action_2_URL__c, notif_Call_to_Action_2_Image__c FROM Station_Content__c WHERE Id = :stationId LIMIT 1];
        return stationContent;
    }
}