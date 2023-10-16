//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreateNonCSGStationUsersExternal implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
   
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {  
        
        system.debug('lets see what we have'+ 'Create'+ create + 'User'+ u  + 'Map keys'+  attributes.keySet()+ 'Map keys'+  attributes.values() + 'federation identifier' + federationIdentifier + 'isStandard'+ isStandard);
        
        system.debug('see User' + create + attributes.get('username') + 'fed identifier' + attributes.get('User.FederationIdentifier')+ attributes.get('User.Email') + attributes.get('User.LastName'));
        
        system.debug('See actula User here'+ User.Email + User.firstName +User.lastName);
       
       if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } 
        
        if (create){
        
             if(u.Email!=null) {
                 
            /*
               String userEmail = u.Email;
               String userName = userEmail.substringBefore('@') + '@sfservices.com';
              //  un = un.replace('@salesforce.com', '@sfservices.com');
                u.Username = userName;
                
             */   
                String un = u.Email;
               un = un.substringBefore('@') + '@sfservices.com';
              //  un = un.replace('@', '@sfservices.com');
                u.Username = un;
                } 
            }
        
        if (create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
                Profile p = [SELECT Id FROM Profile WHERE Name='CSG Base Profile'];
                u.profileId= p.id;
                }        
           }
        
        if (attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        
        if (attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        } 
        
        if (attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        } 
        
        if (attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        
        
        String uid = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        
        if (attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if (create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        
        if (attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if (create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        
        if (attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if (create) {
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
        
        if (attributes.containsKey('User.TimeZoneSidKey')) {
            u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if (create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        
        if (attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if (create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }
        
        /*
        * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
        * If your identity provider sends these User fields as attributes along with Contact 
        * or Account fields, you must modify the logic in this class to update either these 
        * User fields or the Contact and Account fields.
        */
        
        //Handle custom fields here
        system.debug('print User to see all attribute' + u);
        if (!create && u!=null) {
            update(u);
        }
    }
    
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,String federationIdentifier, Map<String, String> attributes, String assertion) {
       
           handleUser(create, u, attributes, federationIdentifier, true); 
    }
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('createUser###'+ 'Id'+ samlSsoProviderId + 'CommunityId'+ communityId + + 'portalId'+  portalId+ 'federationIdentifier'+  federationIdentifier + 'Map keys set'+  attributes.keySet()+ 'Map keys values'+  attributes.values()   + 'assertion'+ assertion);
        
        for(String str : attributes.keySet()){
            system.debug('what we have in Map'+ str +attributes.get(str));
        }
        
        User u = new User();
        handleJit1(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        
        system.debug('Exit the class and everything looks good' + u.lastName);
        return u;
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('updateUser###'+ 'User Id'+ userId+ 'Id'+ samlSsoProviderId + 'CommunityId'+ communityId + + 'portalId'+  portalId+ 'federationIdentifier'+  federationIdentifier + 'Map keys set'+  attributes.keySet()+ 'Map keys values'+  attributes.values()   + 'assertion'+ assertion);
        for(String str : attributes.keySet()){
            system.debug('what we have in Map'+ str +attributes.get(str));
        }
        
        
           
         User u = [SELECT Id, FirstName,LastName,federationIdentifier,  Email FROM User WHERE federationIdentifier = :federationIdentifier ];
          
          
        
        handleJit1(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    
   private void handleJit1(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,String federationIdentifier, Map<String, String> attributes, String assertion) {
       
        System.debug('### AES attributes '+attributes);
        System.debug('### AES attributes '+attributes.get('userId')); 
        
        String ssoEmail = attributes.get('email');
        
        system.debug('users ssoEmail: '+ ssoEmail);
        
        UserContactUtil.doNotExecuteTrigger = true; 

        Org62_User__x org62User = new Org62_User__x();
       // Query External Object
           org62User = AutocreateNonCSGStationOrg62User.findBySSOEmail(ssoEmail);
        
        //  List<User> usertemplist= [Select Id, name from User where email = :ssoEmail];
        if (org62User!=null){
            
              System.debug('### non CSG user'); 
              System.debug('### create user'); 
             
             
                  setupUser(u, org62User, create);
                   
               }
        
        handleUser(create, u, attributes, federationIdentifier, true);
    } 
    
    
   public Void setupUser(User u, Org62_User__x externalUser, Boolean ins) {
        if (ins) {
            String un = externalUser.Username__c;
        //    un = un.replace('@salesforce.com', '@sfservices.com');
            u.FirstName = externalUser.FirstName__c;
            u.LastName = externalUser.lastName__c;
            u.Username = un;
            u.Email = externalUser.Email__c;
     //       u.Alias = externalUser.Alias__c;
          u.ProfileId = [select Id from Profile where name =: 'CSG Base Profile'].Id;
            u.CommunityNickname = externalUser.CommunityNickname__c;
            u.LanguageLocaleKey = externalUser.LanguageLocaleKey__c;
            u.LocaleSidKey = externalUser.LocaleSidKey__c;
            u.TimeZoneSidKey = externalUser.TimeZoneSidKey__c;
            u.EmailEncodingKey = externalUser.EmailEncodingKey__c;
        }
        
       /*
        if (!ins && u.Email != externalUser.Email__c) {
            u.Email = externalUser.Email__c;
        }
        */
    //    u.FederationIdentifier = externalUser.FederationIdentifier__c;
        u.Department = externalUser.Department__c;
 //       u.IsActive = externalUser.IsActive__c;
        u.Title = externalUser.Title__c;
        
        u.Hire_Date__c = externalUser.Hire_Date_c__c;
        u.JobCode__c = externalUser.JobCode_c__c;
        u.BU__c = externalUser.BU_c__c;
        u.Business_Unit__c = externalUser.Business_Unit_c__c;
        u.JobFamily__c = externalUser.JobFamily_c__c;
        u.JobProfile__c = externalUser.JobProfile_c__c; //GR:Sep 17, 2018 to map XD
        //   u.Support_Subgroup__c = externalUser.Support_Subgroup_c__c; //GR:Nov 26, 2018 to map specialists
        u.JobGrade__c = externalUser.JobGrade_c__c;
        u.Street = externalUser.Street__c;
        u.City = externalUser.City__c;
        u.State = externalUser.State__c;
        u.PostalCode = externalUser.PostalCode__c;
        u.Country = externalUser.Country__c;
        u.Org62Id__c = externalUser.ExternalId;
        u.Mgmt_Chain_Hierarchy_Level_07__c = externalUser.Mgmt_Chain_Level_07_c__c;
        //  u.Continuous_Service_Date__c = externalUser.Continuous_Service_Date_c__c;
        u.Phone = externalUser.Phone__c;
        //  u.Is_LOA__c = externalUser.Sick_Leave_c__c;
        //   u.Acquired_Company__c = externalUser.Acquired_Company_c__c;
        //     u.Skill_Type__c = externalUser.Skill_Type_c__c;
        
        System.debug('setup user for insert ' + ins + '::' + u);
        
    } 
}