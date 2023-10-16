@isTest
private class GDC_SlotBookingFiltersControllerTest {
    
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
        Event slot1 = new Event(StartDateTime = System.now().addHours(2), EndDateTime = System.now().addHours(3), WhoId = interviewer.id, RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Regular');
        Event slot2 = new Event(StartDateTime = System.now().addDays(2), EndDateTime = System.now().addDays(2), RecordTypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('GDC_Interview_Slot').getRecordTypeId(), GDC_Slot_Status__c = 'Available', GDC_Slot_Type__c = 'Hiring Event');
        insert new List<Event>{slot1, slot2};
    }

    @IsTest
    static void testGetUiPicklistValues(){
        User recruiter = [Select id from User where Alias = 'recuse'];
        Test.startTest();
        System.runAs(recruiter) {
            GDC_SlotBookingFiltersController.UIPicklistWrapper wrap = GDC_SlotBookingFiltersController.getPicklistValuesForUi();
            System.assertNotEquals(0, wrap.postingOptions.size());
            System.assertNotEquals(0, wrap.hiringManagerOptions.size());
            System.assertNotEquals(0, wrap.skillOptions.size());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetInterviewersBasedOnFilters() {
        User recruiter = [Select id from User where Alias = 'recuse'];
        Contact hm = [Select id from Contact where GDC_Is_Hiring_Manger__c = true];
        Test.startTest();
        System.runAs(recruiter) {
            GDC_SlotBookingFiltersController.FiltersWrapper wrap = new GDC_SlotBookingFiltersController.FiltersWrapper();
            wrap.jobPosting = 'Technical Consultant';
            wrap.skill = 'Round 1';
            wrap.hiringManager = hm.id;
            List<GDC_SlotBookingFiltersController.PicklistValue> interviewers = GDC_SlotBookingFiltersController.getInterviewersBasedOnFilters(JSON.serialize(wrap));
            System.assertEquals(1, interviewers.size());
        }
        Test.stopTest();
    }

    /**
    @IsTest
    static void testGetInterviewerEmailsBasedOnFiltersForFlow() {
        User recruiter = [Select id from User where Alias = 'recuse'];
        Contact hm = [Select id from Contact where GDC_Is_Hiring_Manger__c = true];
        Event e = [SELECT ID FROM Event LIMIT 1]; //Soni Added
        Test.startTest();
        System.runAs(recruiter) {
            GDC_SlotBookingFiltersController.FiltersWrapper wrap = new GDC_SlotBookingFiltersController.FiltersWrapper();
            wrap.jobPosting = 'Technical Consultant';
            wrap.skill = 'Round 1';
            wrap.hiringManager = hm.id;
            wrap.eventRecord = e; //Soni Added
            List<String> interviewerEmails = GDC_SlotBookingFiltersController.getInterviewersBasedOnFiltersForFlow(new List<GDC_SlotBookingFiltersController.FiltersWrapper>{wrap});
            System.debug('this: '+interviewerEmails);
            System.assertEquals(1, interviewerEmails.size());
        }
        Test.stopTest();
    } **/

    @isTest
    static void testSendEmailtoInterviewerBatch() {
        Contact interviewer = [Select id from contact where email = 'testinterviewer4782@sf.com'];
        Delete[Select id from Event where whoId =: interviewer.id];
        Test.startTest();
            GDC_SendEmailToInterviewersBatch bt = new GDC_SendEmailToInterviewersBatch(false, null);
            Database.executeBatch(bt);
        Test.stopTest();
    }

    @isTest
    static void testSendEmailtoInterviewerBatchWithManager() {
        Contact interviewer = [Select id from contact where email = 'testinterviewer4782@sf.com'];
        Delete[Select id from Event where whoId =: interviewer.id];
        Test.startTest();
            GDC_SendEmailToInterviewersBatch bt = new GDC_SendEmailToInterviewersBatch(true, null);
            Database.executeBatch(bt);
        Test.stopTest();
    }

    @isTest
    static void testSendEmailBatchScheduler() {
        String cronExp = '0 15 17 ? * MON';
        Test.startTest();
            String jobId = System.schedule('Send Emails',  cronExp, new GDC_SendEmailToInterviewersScheduler(false));
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronExp, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }

    @isTest
    static void testGetHiringEvents(){
        Test.startTest();
            List<Event> hiringEvents = GDC_SlotBookingFiltersController.getFutureHiringEvents();
            System.assertEquals(1, hiringEvents.size());
        Test.stopTest();
    }

    @isTest
    static void testCreateNewHiringEvents(){
        Test.startTest();
            GDC_SlotBookingFiltersController.createNewHiringEvent(Date.today().addDays(5));
            System.assertEquals(2, [Select id, ActivityDate, StartDateTime from Event where RecordType.DeveloperName = 'GDC_Interview_Slot' AND GDC_Slot_Type__c = 'Hiring Event' AND StartDateTime >= TODAY].SIZE());
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteHiringEvents(){
        Map<Id, Event> hiringEvents = new Map<Id, Event>([Select id, ActivityDate, StartDateTime from Event where RecordType.DeveloperName = 'GDC_Interview_Slot' AND GDC_Slot_Type__c = 'Hiring Event' AND StartDateTime >= TODAY]);
        Test.startTest();
            GDC_SlotBookingFiltersController.deleteHiringEvents(new List<Id>(hiringEvents.keySet()));
            System.assertEquals(0, [Select id, ActivityDate, StartDateTime from Event where RecordType.DeveloperName = 'GDC_Interview_Slot' AND GDC_Slot_Type__c = 'Hiring Event' AND StartDateTime >= TODAY].SIZE());
        Test.stopTest();
    }

    /**
    @isTest
    static void getInterviewersBasedOnFiltersForFlowNegative(){
        Test.startTest();
            GDC_SlotBookingFiltersController.FiltersWrapper wrap = new GDC_SlotBookingFiltersController.FiltersWrapper();
            wrap.jobPosting = 'Senior Technical Consultant';
            wrap.skill = 'Round 3';
            List<String> interviewerEmails = GDC_SlotBookingFiltersController.getInterviewersBasedOnFiltersForFlow(new List<GDC_SlotBookingFiltersController.FiltersWrapper>{wrap});
            System.assertEquals(null, interviewerEmails);
        Test.stopTest();
    } **/
}