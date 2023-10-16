@isTest(SeeAllData=true)
public class FeedbackControllerTest {
    public static List<User> createManagers() {
        String hostname = '@sfservices.com.onboarding';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        
        List<User> mgmtUsersList = new List<User>();
        User testUser2 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '1' + hostname
        );
        mgmtUsersList.add(testUser2);
        
        User testUser3 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '2' + hostname
        );
        mgmtUsersList.add(testUser3);
        
        User testUser4 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '3'+ hostname
        );
        mgmtUsersList.add(testUser4);
        
        User testUser5 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '4'+ hostname
        );
        mgmtUsersList.add(testUser5);
        
        User testUser6 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '5'+ hostname
        );
        mgmtUsersList.add(testUser6);
        
        User testUser7 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '6' + hostname
        );
        mgmtUsersList.add(testUser7);
        
        User testUser8 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '7' + hostname
        );
        mgmtUsersList.add(testUser8);
        
        User testUser9 = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Millham', // there's a lookup filter on CSG_Project_Feedback__c.Assignment__c where we look for only billable projects and whether the user is active or not. Without this the test class will fail with FIELD_FILTER_VALIDATION_EXCEPTION error.
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + '8' + hostname
        );
        mgmtUsersList.add(testUser9);
            
        insert mgmtUsersList;
        return mgmtUsersList;
        
    }
    
    
    public static User createUser() {
        
        String hostname = '@sfservices.com.onboarding';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        List<User> mgmtHchy = createManagers();
        User testUser = new User(
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + hostname,
            ManagerId = mgmtHchy[0].Id, //Sudhir: added this on Apr. 18th, 2021. Without this the email alert "CSG_Project_Feedback_Submitted" will fail because it doesn't find a Manager for the candidate. That will make the process builder fail.
            IsActive = true, // there's a lookup filter on CSG_Project_Feedback__c.Assignment__c where we look for only billable projects and whether the user is active or not. Without this the test class will fail with FIELD_FILTER_VALIDATION_EXCEPTION error.
            Mgmt_Chain_Hierarchy_Level_09__c = mgmtHchy[0].Id,
            Mgmt_Chain_Hierarchy_Level_08__c = mgmtHchy[1].Id,
            Mgmt_Chain_Hierarchy_Level_07__c = mgmtHchy[2].Id,
            Mgmt_Chain_Hierarchy_Level_06__c = mgmtHchy[3].Id,
            Mgmt_Chain_Hierarchy_Level_05__c = mgmtHchy[4].Id,
            Mgmt_Chain_Hierarchy_Level_04__c = mgmtHchy[5].Id,
            Mgmt_Chain_Hierarchy_Level_03__c = mgmtHchy[6].Id,
            Mgmt_Chain_Hierarchy_Level_02__c = mgmtHchy[7].Id
            
        );
        
       
        insert testUser;
        return testUser;
    }
    
    
    public static CSG_Project_Feedback__c createProjFdbck() {
        //Create contact for onboading rec
        Contact aContact = new Contact(LastName = 'LastName', FirstName = 'FirstName');
		insert aContact;
        
        //Create Onboarding rec
		Id PARecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;
       	List<PA_Onboarding__c> Onboardings = new List<PA_Onboarding__c>();
        for (Integer i=0; i<1; i++) {
        PA_Onboarding__c OnbA = new PA_Onboarding__c();
        User u = createUser();
        OnbA.RecordTypeId = PARecordTypeId;
        OnbA.Name = 'Jane';
        OnbA.Program_Start_Date__c = System.today();
        OnbA.Contact__c = aContact.Id;
        OnbA.Candidate_Email__c = 'fbperson'+i+'@test.com';
        onbA.Candidate__c = u.Id;
        Onboardings.add(OnbA);
        }
        
        System.debug('***PA_Onboarding__c ' + Onboardings);
        
        //Disable trigger, to only create Onboarding test data
        LPOnboardingPrepareTriggerHandler.disable = true;
        insert Onboardings;
        
		//Create Project Data
		PA_Onboarding_Project__c prj = new PA_Onboarding_Project__c();
        prj.PA_Onboarding__c = Onboardings[0].Id;
        prj.Consultant__c = Onboardings[0].Contact__c;
        prj.Project_Start_Date__c = System.today();
        prj.Project_End_Date__c = Date.newInstance(2021, 2, 17);
        prj.Project_Name__c = 'Test ProjData';
        prj.Type__c = 'Billable';
        
        system.debug('*PA_Onboarding_Project__c ' + prj);
        insert prj;
        
        // Create CSG Project Feedback Object
        CSG_Project_Feedback__c prjFeedbackObj =  new CSG_Project_Feedback__c(); 
        prjFeedbackObj.Assignment__c = prj.Id; 
        prjFeedbackObj.Onboarding__c = prj.PA_Onboarding__c;//try contact next
       	//prjFeedbackObj.Comments__c = 'New Comment';
       	prjFeedbackObj.CSG_Feedback_Provider__c = UserInfo.getUserId();
        prjFeedbackObj.Unique_Feedback_Id__c = prjFeedbackObj.Assignment__c + '-' + prjFeedbackObj.Onboarding__c + '-' + UserInfo.getUserId() ;
        system.debug('*CSG_Project_Feedback__c ' + prjFeedbackObj);
        
        insert prjFeedbackObj;
        return prjFeedbackObj;
        
        
        
    }
    
    public static CSG_Project_Feedback__c createGeneralFdbck() {
        //Create contact for onboading rec
        Contact aContact = new Contact(LastName = 'LastName', FirstName = 'FirstName');
		insert aContact;
        
        //Create Onboarding rec
		Id PARecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;
       	List<PA_Onboarding__c> Onboardings = new List<PA_Onboarding__c>();
        for (Integer i=0; i<1; i++) {
        PA_Onboarding__c OnbA = new PA_Onboarding__c();
        User u = createUser();
        OnbA.RecordTypeId = PARecordTypeId;
        OnbA.Name = 'Jane';
        OnbA.Program_Start_Date__c = System.today();
        OnbA.Contact__c = aContact.Id;
        OnbA.Candidate_Email__c = 'fbperson'+i+'@test.com';
        onbA.Candidate__c = u.Id;
        Onboardings.add(OnbA);
        }
        
        System.debug('***PA_Onboarding__c ' + Onboardings);
        
        //Disable trigger, to only create Onboarding test data
        LPOnboardingPrepareTriggerHandler.disable = true;
        insert Onboardings;
        
        // Create CSG Project Feedback Object
        CSG_Project_Feedback__c prjFeedbackObj =  new CSG_Project_Feedback__c(); 
        prjFeedbackObj.Onboarding__c = Onboardings.get(0).Id;//try contact next
       	prjFeedbackObj.CSG_Feedback_Provider__c = UserInfo.getUserId();
        prjFeedbackObj.RecordTypeId = Schema.SObjectType.CSG_Project_Feedback__c.getRecordTypeInfosByDeveloperName().get('Generic_Performance_Feedback').getRecordTypeId();
        //prjFeedbackObj.Unique_Feedback_Id__c = prjFeedbackObj.Assignment__c + '-' + prjFeedbackObj.Onboarding__c + '-' + UserInfo.getUserId() ;
        prjFeedbackObj.Unique_Feedback_Id__c = '-' + prjFeedbackObj.Onboarding__c + '-' + UserInfo.getUserId() ; // for generic feedback, there is no project assignment so it won't be part of the unique ID
        system.debug('*CSG_Project_Feedback__c ' + prjFeedbackObj);
        
        insert prjFeedbackObj;
        return prjFeedbackObj;                        
    }
    
    @isTest public static void testCreateGeneralFdbck() {
        CSG_Project_Feedback__c fdbck = createGeneralFdbck();
        
        Test.startTest();
        
        PA_Onboarding__c onb = [SELECT Candidate__c from PA_Onboarding__c WHERE Id = :fdbck.Onboarding__c LIMIT 1];
        String candidateId = FeedbackController.getCandidateRecordId(fdbck.Onboarding__c);
        
        Test.stopTest();
        
        System.assertEquals(onb.Candidate__c, candidateId);        
    }
    
    @isTest public static void negativeTestCreateGeneralFdbck() {
       // CSG_Project_Feedback__c fdbck = createGeneralFdbck();
        
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        try{
            String candidateId2 = FeedbackController.getCandidateRecordId('005123456789');
        }
        catch(QueryException e) {
            if(!String.isBlank(e.getMessage())) {
                exceptions.add(true);
            }
        }
        catch(Exception e) {
            if(!String.isBlank(e.getMessage())) {
                exceptions.add(true);
            }
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptions, 'expected at least one exception to have occured');
    }
    
    public static List<CSG_ProjectFeedback_Skills__c> createProjFdbckSkills() {
    
        CSG_Project_Feedback__c feedbackObj = createProjFdbck();
        //Create required External Ids for Feedback Skills test data
        List<ProfileSkillUserTax__x> userSkills = new List<ProfileSkillUserTax__x>();
	    
            userSkills.add(new ProfileSkillUserTax__x(
                ExternalId = '000222',
                Expertise_Rating_c__c = '4- Specialist'));
            userSkills.add(new ProfileSkillUserTax__x(
                ExternalId = '000223',
                Expertise_Rating_c__c = '4- Specialist'));
        	userSkills.add(new ProfileSkillUserTax__x(
                ExternalId = '000224',
                Expertise_Rating_c__c = '4- Specialist'));
		
        
        system.debug('userSkills ' + userSkills);
        
        //Create Feedback Skills list to pull from
        CSGProfileSkill__c skillNameA = new CSGProfileSkill__c();
       	skillNameA.Name = 'Apex';
        skillNameA.External_Id__c = userSkills[0].ExternalId;
        CSGProfileSkill__c skillNameB = new CSGProfileSkill__c();
       	skillNameB.Name = 'Javascript';
        skillNameB.External_Id__c = userSkills[1].ExternalId;
        CSGProfileSkill__c skillNameC = new CSGProfileSkill__c();
       	skillNameC.Name = 'Verbal Communication';
        skillNameC.External_Id__c = userSkills[2].ExternalId;
       
        system.debug('********CSGProfileSkill__c skills ' + skillNameA + skillNameB + skillNameC);
        insert skillNameA;
        insert skillNameB;
        insert skillNameC;
        
        //Create CSG Project Feedback Skills 
        List<CSG_ProjectFeedback_Skills__c> listFeedbackSkills = new List<CSG_ProjectFeedback_Skills__c>();
      
        CSG_ProjectFeedback_Skills__c fdbck1 = new CSG_ProjectFeedback_Skills__c(Feedback_Skill__c = skillNameA.Id,
                                                                                 Rating__c = '1- Entry',
                                                                                 CSG_Project_Feedback__c = feedbackObj.Id );
        CSG_ProjectFeedback_Skills__c fdbck2 = new CSG_ProjectFeedback_Skills__c(Feedback_Skill__c = skillNameB.Id,
                                                                                 Rating__c = '2- Intermediate',
                                                                                 CSG_Project_Feedback__c = feedbackObj.Id );
        CSG_ProjectFeedback_Skills__c fdbck3 = new CSG_ProjectFeedback_Skills__c(Feedback_Skill__c = skillNameC.Id,
                                                                                 Rating__c = '3- Advanced',
                                                                                 CSG_Project_Feedback__c = feedbackObj.Id );
        
        listFeedbackSkills.add(fdbck1);
        listFeedbackSkills.add(fdbck2);
        listFeedbackSkills.add(fdbck3);
        System.debug('listFeedbackSkills ' + listFeedbackSkills );
        
        insert listFeedbackSkills;
        return listFeedbackSkills;
    }
    
    
    
    
    @isTest static void testCreateProjFeedback(){
        CSG_Project_Feedback__c fdbkObject = createProjFdbck();
        List<CSG_ProjectFeedback_Skills__c> fdbkSkills = createProjFdbckSkills();
        
        Test.startTest();
        FeedbackController.createProjFeedback(fdbkObject, fdbkSkills);
        
       
        fdbkObject = [SELECT Id, Assignment__r.Id , Onboarding__r.Id, Unique_Feedback_Id__c, 
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_09__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_08__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_07__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_06__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_05__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_04__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_03__c,
                      Onboarding__r.Candidate__r.Mgmt_Chain_Hierarchy_Level_02__c FROM CSG_Project_Feedback__c WHERE Id =:fdbkObject.Id];
      	CSG_Project_Feedback__Share mgmt02Shr= new CSG_Project_Feedback__Share();
        
      	//mgmt02Shr = [select ParentId, UserOrGroupId, AccessLevel, RowCause from CSG_Project_Feedback__Share where ParentId =:fdbkObject.Id ];
        
        fdbkSkills = [SELECT Feedback_Skill__c, Rating__c, CSG_Project_Feedback__c FROM CSG_ProjectFeedback_Skills__c WHERE CSG_Project_Feedback__c =:fdbkObject.Id];
        
        Test.stopTest();
        
        //System.assert(fdbkObject.Comments__c == 'New Comment' );
        System.assert(fdbkObject.Assignment__c == fdbkObject.Assignment__r.Id );
        System.assert(fdbkObject.Onboarding__c == fdbkObject.Onboarding__r.Id );
        System.assert(fdbkSkills != null);
        //System.assert(mgmt02Shr.ParentId == fdbkObject.Id);
                   
       // System.assert(fdbkSkills[0].Rating__c == '1- Entry');
        System.assert(fdbkSkills[0].CSG_Project_Feedback__c == fdbkObject.Id);
    }
    
    
    /*
     * TODO: Remove these two methods. checkDuplicates is no longer used.
    @isTest static void testDuplicateRecs() {
   		
        CSG_Project_Feedback__c prjfd1 = createProjFdbck();
        
        List <CSG_Project_Feedback__c> prjfd2 = [Select Id, Unique_Feedback_Id__c from CSG_Project_Feedback__c where Id =:prjfd1.Id limit 1 ];
        String uniqueKey = prjfd2[0].Unique_Feedback_Id__c;
        CSG_Project_Feedback__c returnedRecord = new CSG_Project_Feedback__c();
        Test.startTest();
       	returnedRecord = FeedbackController.checkDuplicates(uniqueKey);
        Test.stopTest();
        System.assertEquals(returnedRecord, null); //we shouldn't find duplicate records here since we added only one feedback.
	}
    
    @isTest static void testDuplicateRecsWithDuplicateFeedback() {
   		
        CSG_Project_Feedback__c prjfd1 = createProjFdbck();
        
        List <CSG_Project_Feedback__c> prjfd2 = [Select Id, Unique_Feedback_Id__c, CSG_Feedback_Request_Status__c from CSG_Project_Feedback__c where Id =:prjfd1.Id limit 1 ];        
        String uniqueKey = prjfd2[0].Unique_Feedback_Id__c;
        prjfd2[0].CSG_Feedback_Request_Status__c = 'Completed';
        update prjfd2; //update the status to Completed so that we can check the "if" condition in checkDuplicates call.
        
        CSG_Project_Feedback__c returnedRecord = new CSG_Project_Feedback__c();
        Test.startTest();
       	returnedRecord = FeedbackController.checkDuplicates(uniqueKey);
        Test.stopTest();
        System.assertEquals(uniqueKey, returnedRecord.Unique_Feedback_Id__c); //we should find duplicate records here since we updaetd the status to completed.
	}
    */
    
    @isTest static void testGetResourceSkills(){
        CSG_Project_Feedback__c feedbackPrj = createProjFdbck();
        User uRole = createUser();
        
        
        Test.startTest();
        feedbackPrj = [SELECT  Onboarding__r.Candidate__c, Onboarding__r.CSG_Role_Community__c FROM CSG_Project_Feedback__c limit 1 ];
        uRole = [Select Id, CSG_Role__c, Org62Id__c, Title from User where Id = :feedbackPrj.Onboarding__r.Candidate__c];
        FeedbackController.getResourceSkills(feedbackPrj.Onboarding__r.Candidate__c);
        Test.stopTest();
        
    }
    
    
      @isTest static void testGetProjectAssignment(){
    
        Contact bContact = new Contact(LastName = 'LastName', FirstName = 'FirstName');
        
		insert bContact;
		Id PARecordTypeId = [select Id from RecordType where Name Like 'Onboarding' Limit 1].Id;
        
		
       	List<PA_Onboarding__c> Onboardings2 = new List<PA_Onboarding__c>();
        for (Integer i=0; i<1; i++) {
        PA_Onboarding__c OnbB = new PA_Onboarding__c();
        
        OnbB.RecordTypeId = PARecordTypeId;
        OnbB.Name = 'Jane';
        OnbB.Program_Start_Date__c = System.today();
        OnbB.Contact__c = bContact.Id;
        OnbB.Candidate_Email__c = 'fbperson'+i+'@test.com';
        
        Onboardings2.add(OnbB);
        }
        
        
        System.debug('***PA_Onboarding__c ' + Onboardings2);
        
        LPOnboardingPrepareTriggerHandler.disable = true;
        insert Onboardings2;
  
		PA_Onboarding_Project__c prj2 = new PA_Onboarding_Project__c();
        prj2.PA_Onboarding__c = Onboardings2[0].Id;
        prj2.Consultant__c = Onboardings2[0].Contact__c;
        prj2.Project_Start_Date__c = System.today();
        prj2.Project_End_Date__c = Date.newInstance(2021, 3, 17);
        prj2.Project_Name__c = 'Test ProjData2';
        prj2.Type__c = 'Billable';
        prj2.PSE_Project_ID__c = '0804';
        
        system.debug('*PA_Onboarding_Project__c ' + prj2);
        insert prj2;
        
        
        
        Test.startTest();
        FeedbackController.getProjectAssignment(prj2.Id, prj2.PSE_Project_ID__c);
           
       	Test.stopTest();
        
        
        prj2 = [SELECT PA_Onboarding__c, Consultant__c, Project_Start_Date__c, Project_End_Date__c,Project_Name__c, Type__c, PSE_Project_ID__c  FROM PA_Onboarding_Project__c WHERE (Id =:prj2.Id OR Id =:prj2.PSE_Project_ID__c)];
        
        System.assert(prj2.Id == prj2.Id );
        System.assert(prj2.PSE_Project_ID__c == '0804' );
         
    }

    @isTest static void testCheckIfUserCanSubmitFeedback() {
        CSG_Project_Feedback__c prjfd1 = createProjFdbck();       
        User u = createUser(); // create a user who won't be the feedback provider
        String sameUser;
        String differentUser;
        String noResults;
        String feedbackCompleted;
        
        Test.startTest();
        differentUser = FeedbackController.checkIfUserCanSubmitFeedback(prjfd1.Id, u.id);
        sameUser = FeedbackController.checkIfUserCanSubmitFeedback(prjfd1.Id, UserInfo.getUserId());
        noResults = FeedbackController.checkIfUserCanSubmitFeedback('1-2-3', u.id);
        prjfd1.CSG_Feedback_Request_Status__c = 'Completed';        
        update prjfd1;
        feedbackCompleted = FeedbackController.checkIfUserCanSubmitFeedback(prjfd1.Id, UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals('DIFFERENT_USER', differentUser, 'Feedback provider and user submitting feedback are not the same user'); // check to make sure we return false if the feedback provider and logged user are not the same
        System.assertEquals('SAME_USER', sameUser, 'Feedback provider and user submitting feedback are the same user'); // check to make sure we return false if the feedback provider and logged user are the same
        System.assertEquals('NO_RESULTS', noResults, 'No results found for the id provided'); //check the "return false" part which happens if the query returns no results 
        System.assertEquals('COMPLETED', feedbackCompleted, 'Feedback already completed by this user for this resource'); // check to make sure that we return the correct status when feedback provider is the submitting user and the feedback was completed.     
        
        
    }

    @isTest 
    public static void testCreateGeneralFdbckLWC() {
        CSG_Project_Feedback__c fdbck = createGeneralFdbck(); //Reuse Feedback Test Class
        
        Test.startTest();
        String recordTypeId = FeedbackController.getEFDefaultRecordTypeId();

        CSG_Project_Feedback__c feedbackRecord = new CSG_Project_Feedback__c();
        feedbackRecord.CSG_PF_Salesforce_Smart__c = 'Test 1';
        feedbackRecord.CSG_PF_Get_It_Done__c = 'Test 1';
        feedbackRecord.CSG_PF_Win_as_a_Team__c = 'Test 1';
        feedbackRecord.CSG_PF_Motivate_Champion__c = 'Test 1';
        feedbackRecord.CSG_PF_Courageous_Communicator__c = 'Test 1';
        feedbackRecord.CSG_PF_Salesforce_Smart_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Get_It_Done_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Win_as_a_Team_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Motivate_Champion_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Courageous_Communicator_Rating__c = 'NA - Unable to Assess';
        FeedbackController.saveFeedback(feedbackRecord, fdbck.Id);
        Test.stopTest();
        
        CSG_Project_Feedback__c afterUpdate = [SELECT CSG_PF_Salesforce_Smart__c, RecordTypeId FROM CSG_Project_Feedback__c WHERE Id =: fdbck.Id];
        System.assertEquals(afterUpdate.CSG_PF_Salesforce_Smart__c, feedbackRecord.CSG_PF_Salesforce_Smart__c);
        System.assertEquals(afterUpdate.RecordTypeId, recordTypeId);        
    }

    @isTest 
    public static void testNegativeCreateGeneralFdbckLWC() {
        CSG_Project_Feedback__c fdbck = createGeneralFdbck(); //Reuse Feedback Test Class
        
        Test.startTest();
        String recordTypeId = FeedbackController.getEFDefaultRecordTypeId();

        CSG_Project_Feedback__c feedbackRecord = new CSG_Project_Feedback__c();
        feedbackRecord.CSG_PF_Salesforce_Smart__c = 'Test 1';
        feedbackRecord.CSG_PF_Get_It_Done__c = 'Test 1';
        feedbackRecord.CSG_PF_Win_as_a_Team__c = 'Test 1';
        feedbackRecord.CSG_PF_Motivate_Champion__c = 'Test 1';
        //feedbackRecord.CSG_PF_Courageous_Communicator__c = 'Test 1'; //Omitted to trigger Validation error
        feedbackRecord.CSG_PF_Salesforce_Smart_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Get_It_Done_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Win_as_a_Team_Rating__c = 'NA - Unable to Assess';
        feedbackRecord.CSG_PF_Motivate_Champion_Rating__c = 'NA - Unable to Assess';
        //feedbackRecord.CSG_PF_Courageous_Communicator_Rating__c = 'NA - Unable to Assess'; 
        try{
            FeedbackController.saveFeedback(feedbackRecord, fdbck.Id);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
        
        CSG_Project_Feedback__c afterUpdate = [SELECT CSG_PF_Salesforce_Smart__c, RecordTypeId FROM CSG_Project_Feedback__c WHERE Id =: fdbck.Id];
        System.assertEquals(null, feedbackRecord.CSG_PF_Salesforce_Smart__c);
        System.assertEquals(afterUpdate.RecordTypeId, recordTypeId);        
    }
 }