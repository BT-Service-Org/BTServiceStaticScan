@isTest
public with sharing class StationNotifStripControllerTest {
    @isTest public static void testGetNotificationStripRecord(){
        Station_Content__c  stationContent = new Station_Content__c(Name = 'Test Notif Strip', Content_Type__c = 'Content Version');
        insert stationContent;
        StationNotifStripController.getNotificationStripRecord(stationContent.Id);
    }
}