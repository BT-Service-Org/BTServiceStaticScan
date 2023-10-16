/**
* Author(s): Skills360 Team
* Description: JIT handler to create services user
* CreatedDate: 2022, Sep 20
*/ 
global class AutoCreateServiceUserSSOJITHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
     /**
    @description : handle User method which creates/updates user record with SAML Attributes
    @param create - Boolean
    @param u - User
    @param attributes -  Map<String, String>
    @param federationIdentifier - String
    @param isStandard - Boolean
    */
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {
        for(String target : attributes.values()){
            System.debug(Logginglevel.DEBUG,'*************** Current Target: ' + target); 
            // helpful for debug, spits out the SAML assertions currently received in the SSO request
        }
        
        // fields that are in a standard SAML assertion, and required for a user in SFDC platform
		String ssoEmail = attributes.get('email');        
        
        u.Email = ssoEmail;
	User__x org62User;
        if(create){
            // Querying profile for setting up user
        	Profile p = [SELECT Id, Name FROM Profile WHERE Name = :Label.CSG_Profile ];
            String un = u.Email;
            un = un.substringBefore('@') + Label.CSG_Username_Prefix;
            u.Username = un;
            u.FederationIdentifier = u.Email;
            u.ProfileId = p.Id;
            u.is_SSO_User__c = true;
            
            Boolean isActiveCheck = True;
        
            // Query External Object for user record
            String selectString = 'select is_SSO_User__c,Alias__c,CommunityNickname__c,LanguageLocaleKey__c,LocaleSidKey__c,TimeZoneSidKey__c,'+
                'FirstName__c, LastName__c,Title__c,Username__c,Email__c,EmailEncodingKey__c,ExternalId,' +
                'Street__c, City__c, State__c, PostalCode__c, Country__c,Phone__c,Business_Unit_c__c,Cost_Center_c__c,' +
                'Department__c,IsActive__c,' +
                'FederationIdentifier__c,' +
                'BU_c__c, Hire_Date_c__c,JobCode_c__c,JobFamily_c__c,JobGrade_c__c,JobProfile_c__c ' +
                'from User__x WHERE IsActive__c =:isActiveCheck AND ' +' Email__c =:'+ 'ssoEmail';
            
            List<User__x> userXList =  Database.query(selectString);
            org62User = (userXList.size() > 0) ? userXList[0] : null;
            if(Test.isRunningTest()) {
                //need to create some dummy user 
                 User__x extUser = new User__x(
                     FirstName__c = '4- Specialist',
                     LanguageLocaleKey__c = 'en_US',
                     LocaleSidKey__c = 'en_US',
                     TimeZoneSidKey__c = 'America/Los_Angeles'   ,
                     EmailEncodingKey__c = 'UTF-8'
                );
                setupUser(u, extUser, create);
                
            } 
            if(org62User != null){
                setupUser(u, org62User, create);
            }
        u.FirstName = attributes.containsKey('firstName') ? attributes.get('firstName') : u.FirstName ;
        u.LastName = attributes.containsKey('lastName') ? attributes.get('lastName') : u.LastName ;
        u.Department =  attributes.containsKey('department') ? attributes.get('department') : u.department ;
        u.Title =  attributes.containsKey('title') ? attributes.get('title') : u.title ;
        

        if(attributes.containsKey('alias')) {
            u.Alias = attributes.get('alias');
        }
        else{
            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            
            if (alias!=null && alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
    }
       system.debug(Logginglevel.DEBUG,'user: '+u);  // Display all the user attributes you plan to update/create
        
       if(!create) { 
            u.isActive = TRUE;
            update(u); 
        }
        else{
            	insert u;
		//Update Org62 user with is_SSO_User__C as True 

		if(org62User != null && u.is_SSO_User__c ){
			system.debug(Logginglevel.DEBUG,'updating external object 2: '+org62User); 
			org62User.is_SSO_User__c = TRUE;
			Database.updateAsync(org62User); 
		}
        }
    }
    
    
     /**
    @description : handle JIT method which calls handleUser method
    @param create - Boolean
    @param u - User
    @param samlSsoProviderId -  Id
    @param communityId - Id
    @param portalId - Id
    @param federationIdentifier - String
	@param attributes -  Map<String, String>
    @param assertion - String
    */
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        // we are doing standard CRM users on Aloha SSO, so portalId and communityId are always null, and a custom profile
       handleUser(create, u, attributes, federationIdentifier, false);
    }
    
     /**
    @description : Create User method which creates user record with SAML Attributes
    @param samlSsoProviderId -  Id
    @param communityId - Id
    @param portalId - Id
    @param federationIdentifier - String
	@param attributes -  Map<String, String>
    @param assertion - String
	@return : User
    */
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        setIsGKCUser(samlSsoProviderId,u);
        handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        system.debug('user in create : ' + u);
        return u;
    }
    
    
    /**
    @description : Create User method which creates user record with SAML Attributes
	@param userId -  Id
    @param samlSsoProviderId -  Id
    @param communityId - Id
    @param portalId - Id
    @param federationIdentifier - String
	@param attributes -  Map<String, String>
    @param assertion - String
    */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, Username,Is_GKC_User__c,UserPermissionsKnowledgeUser FROM User WHERE Id=:userId];
        setIsGKCUser(samlSsoProviderId,u);
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        }
   /*
    * Method :      setupUser (User,User__x,Boolean)
    * Description : Maps user fields to external object User__x. Sets additional user attributes for create user use cases.  
    */ 
    public Void setupUser(User u,  User__x externalUser, Boolean ins) {
        if (ins) {
            String un = externalUser.Username__c;
            u.FirstName = externalUser.FirstName__c;
            u.LastName = externalUser.lastName__c;
            u.CommunityNickname = externalUser.CommunityNickname__c;
            u.LanguageLocaleKey = externalUser.LanguageLocaleKey__c;
            u.LocaleSidKey = externalUser.LocaleSidKey__c;
            u.TimeZoneSidKey = externalUser.TimeZoneSidKey__c;
            u.EmailEncodingKey = externalUser.EmailEncodingKey__c;
            }
        u.Department = externalUser.Department__c;
        u.Title = externalUser.Title__c;
        u.Hire_Date__c = externalUser.Hire_Date_c__c;
        u.JobCode__c = externalUser.JobCode_c__c;
        u.BU__c = externalUser.BU_c__c;
        u.Business_Unit__c = externalUser.Business_Unit_c__c;
        u.JobFamily__c = externalUser.JobFamily_c__c;
        u.JobProfile__c = externalUser.JobProfile_c__c;
        u.JobGrade__c = externalUser.JobGrade_c__c;
        u.Street = externalUser.Street__c;
        u.City = externalUser.City__c;
        u.State = externalUser.State__c;
        u.PostalCode = externalUser.PostalCode__c;
        u.Country = externalUser.Country__c;
        u.Org62Id__c = externalUser.ExternalId;
        u.Phone = externalUser.Phone__c;
        } 
    /*
     * Method :      isGKCUser (Id)
     * Description : Evaluates if a Boolean ideantifier named Is_GKC_User__c need to be set on User record.  
	 *               Is_GKC_User__c signifies Global Knowledge Center user and should be set when user logs in clicking GKC Okta tiles in Okta.
     */    
    public void  setIsGKCUser(ID samlSsoProviderId,User u){
    SamlSsoConfig config= [Select MasterLabel from SamlSsoConfig where id=:samlSsoProviderId];
    if(config.MasterLabel =='Okta for Services Central' || config.MasterLabel =='Okta for Services Knowledge Center' ){
        u.Is_GKC_User__c=true;
        u.UserPermissionsKnowledgeUser=true;
        }
    }
}