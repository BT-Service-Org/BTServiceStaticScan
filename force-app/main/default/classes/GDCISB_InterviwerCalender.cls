public without sharing class GDCISB_InterviwerCalender {
    private static Id interviewRTId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId();
	public class FiltersWrapper {
        @AuraEnabled public String hiringManager {get; set;}
        @AuraEnabled public String jobPosting {get; set;}
        @AuraEnabled public String skill {get; set;}
    }
	
	public class EmergencyException extends Exception {}
    
    public string authtoken{get;set;}
    public string refereshtoken{get;set;}
    public string bodyprint{get;set;}
        
    //Settings needed on the google cloud console.One can store this securely in custom settings or an object.
    
    public static final string CLIENT_SECRET='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';//Fill as per your registered app settings in google console
    public static final string CLIENT_ID='1034259972082-af6c77f37lbnc5aed1lj9tilrggnmk3r.apps.googleusercontent.com';//Fill as per your registered app settings in google console
    public static final string REDIRECT_URL='https://sfservices.my.salesforce.com/apex/mycalendar';
    //'https://sfservices--gdcdev.lightning.force.com/lightning/n/My_Calender';
    
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
    
    public static final string GRANT_TYPE='grant_type=authorization_code';
    
    //Scope URL as per oauth 2.0 guide of the google 
    public static final string SCOPE='https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar';
    public static final string STATE='/profile';
    
    //Approval Prompt Constant
    public static final string APPROVAL_PROMPT='force';

    @AuraEnabled
    public static string gapiConnect(){
        return GDCGCalLibrary.gapiConnect();
    }

    @AuraEnabled
    public static string gapiGetToken(String authCode){
        return GDCGCalLibrary.gapiGetToken(authCode);
    }

    @AuraEnabled
    public static string gapiGetCalendarList(String authCode){
        try {
            Datetime today = System.now();
            return GDCGCalLibrary.getEvents(authCode, System.now(), today.addDays(30));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<GDCISB_AppointmentWrapper> generateWrapper(List<Event> appointmentList){
        List<GDCISB_AppointmentWrapper> wrapper = new List<GDCISB_AppointmentWrapper>();
        for(Event appointment : appointmentList) {
            wrapper.add(new GDCISB_AppointmentWrapper(appointment.who.Name, 
                                               appointment.StartDateTime, 
                                               appointment.EndDateTime, 
                                               appointment.Id,
                                               false,
                                               appointment.GDC_Recurred_Slot_Id__c,
                                               appointment.GDC_Slot_Status__c,
                                               appointment.GDC_Slot_Type__c,
                                               appointment.Google_Event_Id__c));    
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static List<GDCISB_AppointmentWrapper> getMyAppointments() {
        Contact interviewer = [Select Id, GDC_Job_Posting__c, GDC_Skill__c, GDC_Hiring_Manager__c from Contact where User_Record__c = :userInfo.getUserId() and GDC_Job_Posting__c  != null limit 1];
        List<String> postings = interviewer.GDC_Job_Posting__c.split(';');
        List<String> skills = interviewer.GDC_Skill__c.split(';');
        
        List<Event> appointmentList = [SELECT Id, StartDateTime, EndDateTime, GDC_Slot_Status__c , who.Name, GDC_Recurred_Slot_Id__c, GDC_Slot_Type__c, Google_Event_Id__c
                                          FROM Event 
                                          Where RecordTypeId = :interviewRTId And (whoId = :interviewer.Id OR 
                                          (GDC_Slot_Type__c = 'Emergency' And GDC_Hiring_Managers_Emergency_Slot__c includes (:interviewer.GDC_Hiring_Manager__c) And GDC_Skill_Emergency_Slot__c in :skills And GDC_Posting_Emergency_Slot__c in :postings) OR GDC_Slot_Type__c = 'Hiring Event')
                                          ORDER BY StartDateTime]; //added additional where clause to query Hiring events
        return generateWrapper(appointmentList);
    }
    
    @AuraEnabled
    public static List<GDCISB_AppointmentWrapper> getInterviwersAppointments(List<Id> interviewers, FiltersWrapper filter) {
        System.debug(interviewers);
        List<Event> appointmentList = [SELECT Id, StartDateTime, EndDateTime, GDC_Slot_Status__c , who.Name, GDC_Recurred_Slot_Id__c, GDC_Slot_Type__c, Google_Event_Id__c
                                          FROM Event  
                                          Where RecordTypeId = :interviewRTId And (whoId in :interviewers OR
                                          (GDC_Slot_Type__c='Emergency' And GDC_Hiring_Managers_Emergency_Slot__c includes (:filter.hiringManager) And GDC_Skill_Emergency_Slot__c = :filter.skill And GDC_Posting_Emergency_Slot__c = :filter.jobPosting And CreatedById = :UserInfo.getUserId()) OR GDC_Slot_Type__c = 'Hiring Event')
                                          ORDER BY StartDateTime]; //added additional where clause to query Hiring events
        return generateWrapper(appointmentList);
    }
    
    private static Boolean getTheEmergencySlots(Event slot){
        Integer slotMonth = slot.StartDateTime.Month();
        Integer slotYear = slot.StartDateTime.Year();
        List<Event> appointmentList = [SELECT Id
                                          FROM Event 
                                          Where GDC_Slot_Type__c='Emergency'  And CreatedById = :UserInfo.getUserId() And CALENDAR_MONTH(StartDateTime) = :slotMonth And CALENDAR_YEAR(StartDateTime) = :slotYear
                                          ORDER BY StartDateTime];
        if(appointmentList != null && appointmentList.size() >= Integer.valueOf(Label.GDC_Maximum_Hiring_Slots_per_month)){
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static List<GDCISB_AppointmentWrapper> saveAppointments(List<Event> slots) {
        try{
            if(slots[0].GDC_Slot_Type__c == 'Emergency' && getTheEmergencySlots(slots[0])){
				throw new EmergencyException('You have already created maximum no of slots that are allowed for this month');
            }
            upsert slots;
            List<Event> appointmentList = [SELECT Id, StartDateTime, EndDateTime, GDC_Slot_Status__c , who.Name, GDC_Recurred_Slot_Id__c, GDC_Slot_Type__c, Google_Event_Id__c
                                          	FROM Event where Id in :slots
                                            ORDER BY StartDateTime];
            return generateWrapper(appointmentList);
        }catch(Exception ex){
			throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<GDCISB_AppointmentWrapper> saveReoccurenceAppointMents(List<Event> slots,String accessToken, String recurrenceRule) {
        try{
            if(slots[0].GDC_Slot_Type__c == 'Emergency' && getTheEmergencySlots(slots[0])){
				throw new EmergencyException('You have already created maximum no of slots that are allowed for this month');
            }
            /*String response = GDCGCalLibrary.patchRecurrence(accessToken,slots[0].Google_Event_Id__c,recurrenceRule);
            Map<String,Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(response);
            String iCalUID  = (String)deserialized.get('iCalUID');
            
            String recurrenceresp = GDCGCalLibrary.getRecurrenceRelatedEvents(accessToken, iCalUID);
            Map<String,Object> deserializedEvents = (Map<String,Object>)JSON.deserializeUntyped(recurrenceresp);

            List<Object> gEvents = (List<Object>)JSON.deserializeUntyped(JSON.serialize(deserializedEvents.get('items')));
            
            for(Integer i=0; i < slots.size(); i++){
                if(String.isBlank(slots[i].Id)){
					Map<String,Object> gEvent = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(gEvents[i]));				
                    slots[i].Google_Event_Id__c = (String)gEvent.get('id');
                }
            }*/
            for(Event slot:slots){
                if(String.isBlank(slot.Id)){
                    Map<String,Object> gEvent = (Map<String,Object>)JSON.deserializeUntyped(GDCGCalLibrary.insertEvents(accessToken,slot.startDateTime,slot.endDateTime,''));
                    slot.Google_Event_Id__c = (String)gEvent.get('id');
                }
            }
            upsert slots;
            List<Event> appointmentList = [SELECT Id, StartDateTime, EndDateTime, GDC_Slot_Status__c , who.Name, GDC_Recurred_Slot_Id__c, GDC_Slot_Type__c, Google_Event_Id__c
                                          	FROM Event where Id in :slots
                                            ORDER BY StartDateTime];
            return generateWrapper(appointmentList);
        }catch(Exception ex){
			throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAppointments(List<Event> slots) {
        try{
        	update slots;
        }catch(Exception ex){
			throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteAppointments(List<Event> slots) {
        delete slots;
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getInterviewer() {
        return [Select Id, Name, GDC_Job_Posting__c, GDC_Skill__c, GDC_Hiring_Manager__c, GCalendar_Token__c  from Contact where User_Record__c= :userInfo.getUserId() and GDC_Job_Posting__c != null limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getEventRecordTypeId() {
        return interviewRTId;
    }
    
    @AuraEnabled
    public static void updateAccessToken(Id conId, String accessToken) {
        update new Contact(Id=conId,GCalendar_Token__c=accessToken);
    }
    
    @AuraEnabled
    public static void deleteOnSFDCWhenDeletedOnGcal(List<String> eventIds) {
		delete [Select Id from Event where Id in :eventIds];
    }
}