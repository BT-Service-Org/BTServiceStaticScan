@isTest
public class GDCISB_InterviwerCalenderTest {
	@TestSetup
    static void makeData(){
        Util.inFutureContext = true;
        Account acc = new Account(Name = 'Salesforce.com - DO NOT TOUCH', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId());
        insert acc;
        User currentUser = [Select id from User where Id = :Userinfo.getUserId()];
        System.runAs(currentUser) {
            Profile p1 = [Select id from Profile where Name = 'CSG Base Profile'];
            User u1 = new User(Alias = 'intucc', Email='testinterviewer4782@sf.com', 
            EmailEncodingKey='UTF-8', FirstName = 'Interviewer', LastName = 'User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id,
            TimeZoneSidKey='Asia/Kolkata', UserName='testinterviewer4782@sf.com.abc');

            User u2 = new User(Alias = 'manucc', Email='testHiringManager123525@sf.com', 
            EmailEncodingKey='UTF-8', FirstName = 'Test', LastName = 'Hiring Manager', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id,
            TimeZoneSidKey='Asia/Kolkata', UserName='testHiringManager123525@sf.com.abc');

            Profile recruiterProf = [Select id from Profile where Name = 'GDC Recruiter Profile'];
            User recruiter = new User(Alias = 'recuse', Email='recruiteruser1342@sf.com', 
            EmailEncodingKey='UTF-8', FirstName = 'Recruiter', LastName = 'User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = recruiterProf.Id,
            TimeZoneSidKey='Asia/Kolkata', UserName='recruiteruser1342@sf.com.abc');

            insert new List<User>{u1, u2, recruiter};
            PermissionSet interviewerPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'GDC_Interviewer'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = interviewerPermSet.Id);
            insert psa1;
        }
        Contact hiringManager = [Select id from Contact where email = 'testHiringManager123525@sf.com'];
        hiringManager.GDC_Is_Hiring_Manger__c = true;
        Contact interviewer = [Select id from Contact where email = 'testinterviewer4782@sf.com'];
        interviewer.GDC_Is_Hiring_Manger__c = false;
        interviewer.GDC_Job_Posting__c = 'Associate Technical Consultant; Technical Consultant';
        interviewer.GDC_Skill__c = 'Round 1';
        interviewer.GDC_Hiring_Manager__c = hiringManager.Id;
        update new List<Contact>{hiringManager,interviewer};
        Event slot1 = new Event(StartDateTime = System.now().addHours(2), Google_Event_Id__c = 'test', EndDateTime = System.now().addHours(3), WhoId = interviewer.id, RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Regular');
        Event slot2 = new Event(StartDateTime = System.now().addDays(2), Google_Event_Id__c = 'test2', EndDateTime = System.now().addDays(2), RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Hiring Event');
        insert new List<Event>{slot1, slot2};
    }

    @IsTest
    static void testGetMyAppointments() {
        User interviewer = [Select id from User where Alias = 'intucc'];
        Test.startTest();
        System.runAs(interviewer) {
			List<GDCISB_AppointmentWrapper> appointMents = GDCISB_InterviwerCalender.getMyAppointments();
            System.assertEquals(2, appointMents.size());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetInterviwersAppointments() {
        User interviewer = [Select id from User where Alias = 'intucc'];
        User recruiter = [Select id from User where Alias = 'recuse'];
        Contact hm = [Select id from Contact where GDC_Is_Hiring_Manger__c = true];
        List<Id> intviewerIds = new List<Id>{interviewer.Id};
        Test.startTest();
        System.runAs(recruiter) {
            GDCISB_InterviwerCalender.FiltersWrapper wrap = new GDCISB_InterviwerCalender.FiltersWrapper();
            wrap.jobPosting = 'Technical Consultant';
            wrap.skill = 'Round 1';
            wrap.hiringManager = hm.id;
            List<GDCISB_AppointmentWrapper> appointMents = GDCISB_InterviwerCalender.getInterviwersAppointments(intviewerIds,wrap);
            System.assertEquals(1, appointMents.size());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveAppointments() {
        User interviewer = [Select id from User where Alias = 'intucc'];
        System.runAs(interviewer) {
            Datetime startTime = Datetime.now().addDays(1);
            Datetime endTime = Datetime.now().addDays(1).addMinutes(30);
            Id interviewRTId = GDCISB_InterviwerCalender.getEventRecordTypeId();
            Id whoId = GDCISB_InterviwerCalender.getInterviewer().Id;
            Event evnt = new Event(StartDateTime = startTime, 
                                   EndDateTime = endTime,
                                   GDC_Slot_Status__c = 'Available',
                                   whoId = whoId,
                                   RecordTypeId = interviewRTId);
            List<GDCISB_AppointmentWrapper> slots = GDCISB_InterviwerCalender.saveAppointments(new List<Event>{evnt});
            //Emergency
            Event emergencySlot = new Event(StartDateTime = startTime, 
                                            EndDateTime = endTime,
                                            GDC_Slot_Status__c = 'Available',
                                            whoId = whoId,
                                            RecordTypeId = interviewRTId,
                                            GDC_Slot_Type__c = 'Emergency');
            GDCISB_InterviwerCalender.saveAppointments(new List<Event>{emergencySlot});
            //update AppointMent
            GDCISB_InterviwerCalender.updateAppointments(new List<Event>{evnt});
            GDCISB_InterviwerCalender.deleteAppointments(new List<Event>{evnt});
        }
    }

    @IsTest
    static void testMiscellaneous() {
        GDCISB_InterviwerCalender cal = new GDCISB_InterviwerCalender();
        cal.authtoken = 'authtoken';
        cal.refereshtoken = 'refreshtoken';
        cal.bodyprint = 'body';
        Contact interviewer = [Select id from Contact where email = 'testinterviewer4782@sf.com'];
        Event evt = [Select id from Event limit 1];
        GDCISB_InterviwerCalender.updateAccessToken(interviewer.id, 'test');
        GDCISB_InterviwerCalender.deleteOnSFDCWhenDeletedOnGcal(new List<String>{evt.Id});

        System.assertEquals('test',[Select id, GCalendar_Token__c from Contact where email = 'testinterviewer4782@sf.com'].GCalendar_Token__c);
    }

    @IsTest
    static void testgapiConnect() {
        Test.startTest();
        String apiConnect = GDCISB_InterviwerCalender.gapiConnect();
        System.assertNotEquals(null, apiConnect);

        Test.setMock(HttpCalloutMock.class, new GDCGCalMock());
        String apiToken = GDCISB_InterviwerCalender.gapiGetToken('test');
        String calendarList = GDCISB_InterviwerCalender.gapiGetCalendarList('test');

        Test.stopTest();
    }

    @isTest
    static void testsaveReoccurenceAppointMents() {
        Contact interviewer = [Select id from Contact where email = 'testinterviewer4782@sf.com'];
        Event slot1 = new Event(StartDateTime = System.now().addHours(4), EndDateTime = System.now().addHours(5), WhoId = interviewer.id, RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Regular');
        Event slot2 = new Event(StartDateTime = System.now().addHours(28), EndDateTime = System.now().addHours(29), WhoId = interviewer.id, RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Regular');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GDCGCalMock());
            GDCISB_InterviwerCalender.saveReoccurenceAppointMents(new List<Event>{slot1, slot2}, 'test', 'test');
        Test.stopTest();
    }

    @isTest
    static void testdeleteGoogleEvent() {
        Event evt = [SELECT ID FROM Event limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GDCGCalMock());
            GDCGCalLibrary.deleteGoogleEvent('test', evt.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateGoogleEvent() {
        Event evt = [SELECT ID FROM Event limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GDCGCalMock());
            GDCGCalLibrary.updateGoogleEvents('test',System.now().addHours(5),System.now().addHours(6),  evt.Id);
        Test.stopTest();
    }
    
}