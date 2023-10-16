/**
  Automate the basic User activation for CSG Services Developers

  The goal is to ensure that all Developers accounts are:
  1> Email address is fixed up
  2> Profile is changed to SysAdmin

  SysAdmins
  1> Email Address is fixed up

**/
global class CSGServicesSandboxPostCopy implements SandboxPostCopy {
	public static final Id SYSADMIN_PROFILEID = getIDForProfile('System Administrator');
	public static final Id SYSADMIN_SSO_PROFILEID = CSGServicesSandboxPostCopy.getIDForProfile('System Admin - SSO');

	public static final String DOTINVALID = '.invalid';
	public static final String DOTINVALID_LIKE = '%' + DOTINVALID;

    global void runApexClass(SandboxContext context) {
        System.debug('Organization Id: ' + context.organizationId());
        System.debug('Sandbox Id: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());

        activateDevelopers();
		activateSysAdmins();
    }

    /**
      Fix the email address and reassign as SysAdmin in Sandbox
    **/
    private static void activateDevelopers() {

    	final List<User> developers = [SELECT Id, Email From User Where IsActive = true and IsInternalDeveloper__c = true LIMIT 50000];
    	final List<User> toActivate = new List<User>();

    	for (User current : developers) {
    		current.email = fixEmail(current.email);
    		current.profileId = SYSADMIN_PROFILEID;
    		toActivate.add(current);
    	}

    	if (!toActivate.isEmpty()) {
    		update toActivate;
    	}
    }

    /**
      Just Fix the email address
    **/
    private static void activateSysAdmins() {


    	final List<User> admins = [SELECT Id, Email
    								 From User Where IsActive = true 
    								  and Email LIKE :DOTINVALID_LIKE
    								  and ProfileId IN  (:SYSADMIN_PROFILEID,:SYSADMIN_SSO_PROFILEID) LIMIT 50000];
    	final List<User> toActivate = new List<User>();

    	for (User current : admins) {
    		current.email = fixEmail(current.email);
    		toActivate.add(current);
    	}

    	if (!toActivate.isEmpty()) {
    		update toActivate;
    	}
    }


    public static String fixEmail(String originalEmail) {

    	if (originalEmail.endswith(DOTINVALID)) {   
    		return originalEmail.replace(DOTINVALID,'');
    	}
    	return originalEmail;
    }

    public static Id getIDForProfile(String profileName) {
    	final Profile theProfile = [SELECT Id,Name from Profile Where Name = :profileName LIMIT 1];
    	System.Debug('Profile: ' + theProfile.id + ' Name: ' + theProfile.name);
    	return theProfile.Id;
    }
}