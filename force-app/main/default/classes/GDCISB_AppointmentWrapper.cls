public with sharing class GDCISB_AppointmentWrapper {
    @AuraEnabled
    public String startTime{get;set;}
    @AuraEnabled
    public String endTime{get;set;}
    @AuraEnabled
    public String name{get;set;}
    @AuraEnabled
    public String recordId{get;set;}
    @AuraEnabled
    public Boolean isItReccuredEvent{get;set;}
    @AuraEnabled
    public Id reccuredSlotId{get;set;}
    @AuraEnabled
    public String status{get;set;}
    @AuraEnabled
    public String typeOfSlot{get;set;}
    @AuraEnabled
    public String gcalEventId{get;set;}

    public GDCISB_AppointmentWrapper(String name, Datetime startTime, Datetime endTime, String recordId, Boolean isItReccuredEvent, Id reccuredSlotId,String status,String typeOfSlot, String gcalEventId) {
        this.name = name;
        this.startTime = String.valueOf(startTime);
        this.endTime = String.valueOf(endTime);
        this.recordId = recordId;
        this.isItReccuredEvent = isItReccuredEvent;
        this.reccuredSlotId = reccuredSlotId;
        this.status = status;
        this.typeOfSlot = typeOfSlot;
        this.gcalEventId = gcalEventId;
    }
}