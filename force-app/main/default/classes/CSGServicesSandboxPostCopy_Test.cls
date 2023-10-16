/**
  Test class for CSGServicesSandboxPostCopy
**/
@isTest
private class CSGServicesSandboxPostCopy_Test {

	public static final String SFDC_DUMMY_ACCOUNT = 'Salesforce.com - DO NOT TOUCH';

	public static final Id SYSADMIN_PROFILEID = CSGServicesSandboxPostCopy.getIDForProfile('System Administrator');
	public static final Id SYSADMIN_SSO_PROFILEID = CSGServicesSandboxPostCopy.getIDForProfile('System Admin - SSO');
	public static final Id STDUSER_PROFILEID = CSGServicesSandboxPostCopy.getIDForProfile('Standard User');
	
	@testSetup static void testSetup() {
		// Create the required Account so that the UserContactTrigger won't fail
		// This is a cheesy hack required because someone wrote the trigger poorly.
		Account dummyAccount = new Account(name=SFDC_DUMMY_ACCOUNT);
		insert dummyAccount;
		System.debug('Dummy Account.id=' + dummyAccount.id);
	}

	@isTest static void test_FixEmail() {
		System.AssertEquals('bobby.white@salesforce.com',CSGServicesSandboxPostCopy.fixEmail('bobby.white@salesforce.com.invalid'));
		System.AssertEquals('bobby.white@salesforce.com',CSGServicesSandboxPostCopy.fixEmail('bobby.white@salesforce.com'));
	}

	@isTest static void test_UserActivation() {


		final String userEmail1 = 'test1@salesforce.com';

		final User testRegularUser = createUser(STDUSER_PROFILEID,userEmail1,false);

		final String userEmail2 = 'test2@salesforce.com';

		final User testDevUser = createUser(STDUSER_PROFILEID,userEmail2,true);

		final String userEmail3 = 'test3@salesforce.com';

		final User testSysAdmin = createUser(SYSADMIN_PROFILEID,userEmail3,false);

		final String userEmail4 = 'test4@salesforce.com';

		final User testSysAdminSSO = createUser(SYSADMIN_SSO_PROFILEID,userEmail4,false);


		Test.startTest();

		Test.testSandboxPostCopyScript(new CSGServicesSandboxPostCopy(), '00D41000000F2sD', '00D41000000F2sD', 'TESTSANDBOX');

		Test.stopTest();

		final User testRegularUserAfter = [SELECT id, profileId, email From User where ID = :testRegularUser.id ];

		System.AssertEquals(testRegularUser.profileId,testRegularUserAfter.ProfileId,'Profile should be unchanged');
		System.AssertEquals(testRegularUserAfter.email,testRegularUser.email,'Email should be scrambled');

		final User testDevUserAfter = [SELECT id, profileId, email From User where ID = :testDevUser.id ];

		System.AssertEquals(testDevUserAfter.profileId,SYSADMIN_PROFILEID,'Profile should be SysAdmin');
		System.AssertEquals(userEmail2,testDevUserAfter.email,'Email should be unscrambled');

		final User testSysAdminAfter = [SELECT id, profileId, email From User where ID = :testSysAdmin.id ];
		System.AssertEquals(testSysAdminAfter.profileId,SYSADMIN_PROFILEID,'Profile should be SysAdmin');
		System.AssertEquals(userEmail3,testSysAdminAfter.email,'Email should be unscrambled');

		final User testSysAdminSSOAfter = [SELECT id, profileId, email From User where ID = :testSysAdminSSO.id ];
		System.AssertEquals(testSysAdminSSOAfter.profileId,SYSADMIN_SSO_PROFILEID,'Profile should be SysAdmin-SSO');
		System.AssertEquals(userEmail4,testSysAdminSSOAfter.email,'Email should be unscrambled');


	}

	private static User createUser(Id theProfileId, String targetEmail,Boolean isDeveloper) {
		User theUser = new User();
		theUser.username=targetEmail + '.csg.'+ Datetime.now().millisecond();

		theUser.lastName = 'Test';
		theUser.Alias = 'Test'+Datetime.now().millisecond();
		theUser.TimeZoneSidKey = 'America/New_York';
		theUSer.LocaleSidKey = 'en_US';
		theUser.EmailEncodingKey = 'ISO-8859-1';
		theUser.LanguageLocaleKey = 'en_US';

		System.debug(theUser.username);

		theUser.email = scramble(targetEmail);
		theUser.profileId = theProfileId;
		theUser.IsInternalDeveloper__c = isDeveloper;

		insert theUser;

		return theUser;
	}

	private static String scramble(String original) {
		return original += '.invalid';
	}
}