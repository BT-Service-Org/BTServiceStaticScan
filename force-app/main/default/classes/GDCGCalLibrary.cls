public with sharing class GDCGCalLibrary {
    
    public static final string CLIENT_SECRET='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';
    public static final string CLIENT_ID='1034259972082-af6c77f37lbnc5aed1lj9tilrggnmk3r.apps.googleusercontent.com';
    public static final string REDIRECT_URL='https://sfservices.my.salesforce.com/apex/mycalendar';
    
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
    
    public static final string GRANT_TYPE='grant_type=authorization_code';
    
    //Scope URL as per oauth 2.0 guide of the google 
    public static final string SCOPE='https://www.googleapis.com/auth/calendar';
    public static final string STATE='/profile';
    
    //Approval Prompt Constant
    public static final string APPROVAL_PROMPT='force';

    public static string gapiConnect(){
        try {
            String x=OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(SCOPE,'UTF-8')+
                '&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+
                '&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+
                '&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;
            return x;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string gapiGetToken(String authCode){
        try {
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(OAUTH_TOKEN_URL);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setBody('code='+authCode+'&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&redirect_uri='+REDIRECT_URL+'&'+GRANT_TYPE);
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string getEvents(String authCode, DateTime startDateTime, DateTime endDateTime){
        try {
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events'+'?timeMax='+json.serialize(endDateTime).replace('"','')+'&timeMin='+json.serialize(startDateTime).replace('"','')+'&showDeleted=true&singleEvents=true');
            req.setHeader('authorization','Bearer '+authCode);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //commenting this since its not in use
    // public static string getRecurrenceRelatedEvents(String authCode, String iCalUID){
    //     try {
    //         Http h          = new Http();
    //         HttpRequest req = new HttpRequest();
    //         String url = 'https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events'+'?iCalUID='+iCalUID+'&singleEvents=true&orderBy=startTime';
    //         req.setEndpoint(url);
    //         req.setHeader('authorization','Bearer '+authCode);
    //         req.setMethod('GET');
    //         HttpResponse res = h.send(req);
    //         return res.getbody();
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }


    /*
    SIMPLE EXAMPLE USAGE:
        Code to run in execute anonymous window:

        System.debug(
            GDCGCalLibrary.insertEvents('ya29.A0ARrdaM8Lgk7QF7whzRJRwUKGA1VC5umDYbhVfnrfb7BvpTV0YeX1jH_D4iB1evrsx_6DQipThCz_3QBGaWHuFD0K8B0KQXtph6nDUBfP_hVQK8778HbzSGscaxmFPE7OvKW3Xg9C9lHKFeSuSHFVw8-VtONu',
            System.now().addDays(1),
            System.now().addDays(1).addHours(1),
            'RRULE:FREQ=DAILY;COUNT=1'
        ));
    */ 
    @AuraEnabled
    public static string insertEvents(String authCode, DateTime startDateTime, DateTime endDateTime, String recurrenceRule){
        try {
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events');
            req.setHeader('authorization','Bearer '+authCode);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            
            String START_TIME = formatDate(startDateTime); //'2022-03-19T10:00:00-05:30';
            String END_TIME = formatDate(endDateTime);//'2022-03-19T11:00:00-05:30';
            String TIMEZONEVAL = 'Asia/Kolkata';
        
            string event = '{'+
                '"summary": "Interview Scheduled",'+
                '"location": "Google Meet",'+
                '"description": "GDC Interview meeting",'+
                '"status": "confirmed",'+
                '"start": {'+
                    '"dateTime": "'+START_TIME+'",'+
                    '"timeZone": "'+TIMEZONEVAL+'"'+
                '},'+
                '"end": {'+
                    '"dateTime": "'+END_TIME+'",'+
                    '"timeZone": "'+TIMEZONEVAL+'"'+
                '},'+
                (String.isNotBlank(recurrenceRule)?
                ('"recurrence": ['+
                    '"'+recurrenceRule+'"'+ //RRULE:FREQ=DAILY;COUNT=1
                '],'):'')+
                '"attendees": [{"email": "'+UserInfo.getUserEmail()+'","responseStatus": "accepted"}],'+
                '"conferenceData": {'+
                    '"createRequest": {'+
                        '"requestId": "meeting_interview",'+
                        '"conferenceSolutionKey": {'+
                            '"type": "hangoutsMeet"'+
                        '}'+
                    '}'+
                '},'+
                '"reminders": {'+
                    '"useDefault": "False",'+
                    '"overrides": ['+
                        '{"method": "email", "minutes": "1440"},'+
                        '{"method": "popup", "minutes": "10"}'+
                    ']'+
                '}'+
            '}';


            req.setBody(event);
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateGoogleEvents(String authCode, DateTime startDateTime, DateTime endDateTime, String eventId){
        try {
            String gEventId = [Select Id,Google_Event_Id__c from Event where Id=:eventId]?.Google_Event_Id__c;
            if(String.isBlank(gEventId)){
                return '{}';
            }
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events/'+gEventId);
            req.setHeader('authorization','Bearer '+authCode);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('PATCH');
            
            String START_TIME = formatDate(startDateTime); //'2022-03-19T10:00:00-05:30';
            String END_TIME = formatDate(endDateTime);//'2022-03-19T11:00:00-05:30';
            String TIMEZONEVAL = 'Asia/Kolkata';
            
            string event = '{'+
                '"start": {'+
                    '"dateTime": "'+START_TIME+'",'+
                    '"timeZone": "'+TIMEZONEVAL+'"'+
                '},'+
                '"end": {'+
                    '"dateTime": "'+END_TIME+'",'+
                    '"timeZone": "'+TIMEZONEVAL+'"'+
                '}'+
            '}';
            
            req.setBody(event);
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //commenting this since it is not in use
    // public static string patchRecurrence(String authCode, String eventId, String recurrenceRule){
    //     try {
    //         Http h          = new Http();
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events/'+eventId);
    //         req.setHeader('authorization','Bearer '+authCode);
    //         req.setHeader('Content-Type', 'application/json');
    //         req.setMethod('PATCH');
        
    //         string event = '{'+
  	// 					'"recurrence": ['+
    // 						'"'+recurrenceRule+'"'+
	// 					']'+
	// 				'}';


    //         req.setBody(event);
    //         HttpResponse res = h.send(req);
    //         return res.getbody();
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    /*
    WHY DO WE NEED UPDATES?
    CAN UPDATE NOT BE HANDLED BY DELETE AND INSERT FOR OUR USE CASE??
    IF NOT, WHAT OTHER FACTORS ARE WE LOOKING AT TO UPDATE ON AN INVITE??

    public static string updateEvents(String authCode, DateTime startDateTime, DateTime endDateTime, String eventId){
        try {
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events/eventId');
            req.setHeader('authorization','Bearer '+authCode);
            req.setMethod('PUT');
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
	@AuraEnabled
    public static string deleteGoogleEvent(String authCode, String eventId){
        try {
            String gEventId = [Select Id,Google_Event_Id__c from Event where Id=:eventId].Google_Event_Id__c;
            if(String.isBlank(gEventId)){
                return '';
            }
            Http h          = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+UserInfo.getUserEmail()+'/events/'+gEventId);
            req.setHeader('authorization','Bearer '+authCode);
            req.setMethod('DELETE');
            HttpResponse res = h.send(req);
            return res.getbody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Takes regular dateTime variable and converts it to the Gcal format
    public static string formatDate(DateTime dt){
        String formatStr = 'yyyy-MM-dd\'T\'HH:mm:\'00\'';
        String finalString = dt.format(formatStr)+'+05:30';
        return finalString;
    }
}