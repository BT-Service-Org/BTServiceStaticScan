/*****************************************
* File: TestLPOnboardingTriggerHandler
* Author: William Steele-Salesforce PA
* Description: Test Trigger Handler logic for PA_Onboarding__c
******************************************/
@IsTest
private class TestLPOnboardingTriggerHandler {

	static testMethod void testNewUserContactPA(){
		
        Account SFAcct = new Account(Name='Salesforce.com');
        insert SFAcct;
        
        lp_Learning_Path__c newLP = new lp_Learning_Path__c(Name='Program Architect (Accel.8)');
        insert newLP;
        
        Id SCRecordTypeId = [select Id from RecordType where Name Like 'SC Onboarding' Limit 1].Id;
        Id PARecordTypeId = [select Id from RecordType where Name Like 'PA' Limit 1].Id; // Onboarding'
        System.debug('@@100-TestLPOnboardingTriggerHandler:SCRecordTypeId: '+SCRecordTypeId+' for SC_Onboarding');
        System.debug('@@101-TestLPOnboardingTriggerHandler:PARecordTypeId: '+PARecordTypeId+' for PA_Onboarding'); 
        
		Test.startTest();

        DateTime now = System.Now();
        String keyNum = ''+now.year()+now.month()+now.day()+now.hour()+now.minute()+now.second();
        String keyNow = ''+now.hour()+now.minute()+now.second();
        System.debug('102-Key num: '+keyNum+' keyNow: '+keyNow);
        String userName = 'template';
        
        Profile p = [select id from Profile where name = 'System Administrator'];
        List<Contact> cx = new List<Contact>();
        cx.add(new Contact(FirstName='LPOnboardingtest',
                                 lastName='SC Template LPOnboardinguser '+keyNum,
                                 email='sc_LPOnboarding_'+keyNum+'@email.com'));
        cx.add(new Contact(FirstName='LPOnboardingtest',
                                 lastName='PA_Template LPOnboardinguser '+keyNum,
                                 email='pa_LPOnboarding_'+keyNum+'@email.com'));
        insert cx;
		System.debug('@@103-TestLPOnboardingTriggerHandler:inserted Contact: '+cx); 
        
        User ux = new User(Alias = 'tuser',
                           FirstName=userName, LastName = 'User_'+keyNum,
                           Username = ''+userName+keyNum+'_user@sfservices.com.qa',
                           ProfileId = p.Id,
                           Email = ''+userName+keyNum+'_user@sfservices.com.qa',EmailEncodingKey = 'UTF-8',
                           LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                           TimeZoneSidKey = 'America/Los_Angeles');

        System.debug('@@104-TestLPOnboardingTriggerHandler:PRE-inserted User: '+ux); 
        insert ux;
        System.debug('@@105-TestLPOnboardingTriggerHandler:inserted User: '+ux); 

        //Id workingContactId=[select Id from Contact where Id='0033000001r0qpMAAQ'].Id;
        System.debug('@@106-TestLPOnboardingTriggerHandler:using Contact Id: '+cx[0].Id+' user Id: '+ux.Id); 
        //Insert the onboarding templates   
        PA_Onboarding__c pot = new PA_Onboarding__c();
        PA_Onboarding_Property__c pop = new PA_Onboarding_Property__c();
        System.debug('@@107-TestLPOnboardingTriggerHandler:attempting to insert SC Template'); 
        pot = new PA_Onboarding__c(Name='SC Template'+keyNum,
                                  Program_Start_Date__c=System.today(),
                                  Contact__c=cx[0].Id,
                                  Candidate__c=ux.Id,//System.UserInfo.getUserId(),
                                  Candidate_Email__c='sc_template_'+keyNum+'@salesforce.com',
                                  OwnerId=ux.Id,
                                  RecordTypeId=SCRecordTypeId,
                                  //Org62_User_ID__c=ux.Id,
                                  Program__c='Observer'
        );
        System.debug('@@108-TestLPOnboardingTriggerHandler:PRE-inserted PA_Onboarding__c: '+pot); 
        insert pot;
        System.debug('@@109-TestLPOnboardingTriggerHandler:inserted PA_Onboarding__c: '+pot); 
        System.debug('@@110-TestLPOnboardingTriggerHandler:----------inserted SC Template!!'); 
        
        System.debug('@@111-TestLPOnboardingTriggerHandler:attempting to insert SC Property'); 
        pop.Name='SC Template Onboarding Id';
        pop.Key__c='SC Template Onboarding Id';
        pop.Value__c=pot.Id;
        insert pop;
        System.debug('@@112-TestLPOnboardingTriggerHandler:----------inserted SC Property!!'); 
        //the Template PA Onboarding Id needs to be loaded before the loading of the template (go figure)
        //so, put the Template PA Onboarding Id out there with the SC template Id, then go and update it later
        pop.Id=null;// = new PA_Onboarding_Property__c();
        pop.Name='Template PA Onboarding Id';
        pop.Key__c='Template PA Onboarding Id';
        insert pop;

        System.debug('@@113-TestLPOnboardingTriggerHandler:attempting to insert PA Template: '+
                     ' candidateId: '+ux.Id+' contactId: '+cx[1].Id); 
        pot = new PA_Onboarding__c(Name='PA Template_'+keyNum,
                                  Program_Start_Date__c=System.today(),
                                  Contact__c=cx[1].Id,
                                  Candidate__c=ux.Id,//System.UserInfo.getUserId(),
                                  Candidate_Email__c='pa_template_'+keyNum+'@salesforce.com',
                                  OwnerId=ux.Id,
                                  RecordTypeId=PARecordTypeId,
                                  //Org62_User_ID__c=ux.Id,
                                  Program__c='Observer'
        );
        System.debug('@@114-TestLPOnboardingTriggerHandler:attempting to insert PA Template: '+pot);
        try {
	        insert pot;
        } catch (DMLException e) {
            System.debug('@@114.4-TestLPOnboardingTriggerHandler:received the following error when trying '+
                        'to insert the PA Template: '+e.getMessage());
        }
        System.debug('@@115-TestLPOnboardingTriggerHandler:----------inserted PA Template!! Id: '+pot.Id); 
        System.debug('@@116-TestLPOnboardingTriggerHandler:attempting to insert PA Property'); 
        //pop.Name='Template PA Onboarding Id';
        //pop.Key__c='Template PA Onboarding Id';
        pop.Value__c=pot.Id;
        update pop;
        System.debug('@@117-TestLPOnboardingTriggerHandler:----------inserted PA Property!!'); 
       
        List<Learning_Domain__c> lds = buildLearningDomain(pop.Id);
        insert lds;
        
        userName = 'onboarding';

		List<User> luser = new List<User>();
		
        Integer testRange=1;
        System.debug('@@200-TestLPOnboardingTriggerHandler:WE are going to start inserting users: size: '+testRange); 
		for(Integer x=0; x<testRange; x++){
			User u = new User();
			u.Alias = ''+x+keyNow;
            u.FirstName = userName;
			u.LastName = 'User_'+keyNum+'_'+x;
			u.Username = ''+userName+keyNum+'_'+x+'_user@sfservices.com.qa';
			u.Email = ''+userName+keyNum+'_'+x+'_user@sfservices.com.qa';
			u.EmailEncodingKey = 'UTF-8';
			u.ProfileId = p.Id;
			u.LanguageLocaleKey = 'en_US';
			u.LocaleSidKey = 'en_US';
			u.TimeZoneSidKey = 'America/Los_Angeles';
			
	        System.debug('@@210-TestLPOnboardingTriggerHandler:prepared user#: '+x+': '+u); 
			luser.add(u);
		}
		
		
	        System.debug('@@220-TestLPOnboardingTriggerHandler:PREPARING to insert '+luser.size()+' users: '+luser); 
        /**/
			insert luser;
			
		/**/
		Test.stopTest();
		
		/**/
        List<String> uId = new List<String>();
		for(User user : luser){
			uId.add(user.Id);
		}
		
		List<Contact> lcreatedContacts = new List<Contact>();
		lcreatedContacts = [select id,Name from Contact where Id=:cx];
        System.debug('##300-TestLPOnboardingTriggerHandler -- contacts found: '+lCreatedContacts.size());
        System.assert(lCreatedContacts.size()>0, 'Contacts Created!');
		

		List<PA_Onboarding__c> lcreatedPAs = new List<PA_Onboarding__c>();
		lcreatedPAs = [select id,Name,Candidate_Email__c from PA_Onboarding__c 
                       where Name Like 'PA-%'];
        System.debug('##310-TestLPOnboardingTriggerHandler -- PA Onboarding records found: '+lcreatedPAs.size()+
                    ' number of users created: '+luser.size());
        System.debug('##320-TestLPOnboardingTriggerHandler -- PA Onboarding records: '+lcreatedPAs);
        System.assert(lcreatedPAs.size()==testRange, 'PA Onboarding Records NOT Created!');
		/**/
	}
    //List<Learning_Domain__c> lds = buildLearningDomain(pop.Id);
    private static List<Learning_Domain__c> buildLearningDomain (Id pId) {
        List<Learning_Domain__c> newDomains = new List<Learning_Domain__c>();
        Learning_Domain__c domain = new Learning_Domain__c();
        Integer seq = 1;
        List<String> skills = new List<String>{'Application Design','Sharing & Security','Apex & VF',
            'Integration Architecture','Single Sign On','Large Data Volume','Communities & Sites',
            'Change Management','Mobile'};
            for (String skill: skills ) {
                domain = new Learning_Domain__c();
                domain.PA_Onboarding__c = pId;
                domain.Sequence__c = seq++;
                domain.Category__c = 'Technical Skill';
                domain.Skill__c = skill;
                System.debug('%%%1000-adding new domain: '+domain);
                newDomains.add(domain);                
            }
        System.debug('%%%1099-adding new domains: '+newDomains.size());
        
        return newDomains;
    }
}
        /*        Level__c                = role,
                Program__c              = program, 
                Region__c               = pas.Region__c 
	    */
                                  /*Contact__c=[Select Id From Contact 
                                              Where Id In (Select ContactId From User
                                                           Where Id = :UserInfo.getUserId())].Id,*/