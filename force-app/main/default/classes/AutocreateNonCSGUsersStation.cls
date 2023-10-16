//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreateNonCSGUsersStation implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
    @TestVisible private static  List<Org62_User__x> org62UserMockList  = new  List<Org62_User__x>(); 
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {  
        
        system.debug('lets see what we have'+ 'Create'+ create + 'User'+ u  + 'Map keys'+  attributes.keySet()+ 'Map keys'+  attributes.values() + 'federation identifier' + federationIdentifier + 'isStandard'+ isStandard);
        
        system.debug('see User' + create + attributes.containsKey('User.Username') + 'fed identifier' + attributes.containsKey('User.FederationIdentifier'));
        
        system.debug('See actula User here'+ User.Email + User.firstName +User.lastName);
        if (create && attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.username');
        } else {
            u.Username = attributes.get('username');
        }
        
        if(u.Username==null){
            u.Username    = attributes.get('username');
        }
        
        if (create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        
        if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
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
            system.debug('see alias'+ alias);
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
        
        if (!create) {
            update(u);
        }
    }
    
    private User handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,String federationIdentifier, Map<String, String> attributes, String assertion) {
        Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
        List<UserSync__mdt> userSyncInfo = [SELECT Field_API_name__c, Field_Values__c,Type__c FROM UserSync__mdt where Active__c = true AND Field_API_name__c LIKE '%Level_02%'];
        
        System.debug('### AES attributes '+attributes);
        System.debug('### AES attributes '+attributes.get('userId')); 
        
        String ssoEmail = attributes.get('email');
        
        system.debug('users ssoEmail: '+ ssoEmail);
        
        UserContactUtil.doNotExecuteTrigger = true; 
        List<Org62_User__x> org62User = new List<Org62_User__x>();
        if (!Test.isRunningTest()){
            org62User = [SELECT Id,Email__c,Mgmt_Chain_Level_02_c__c FROM Org62_User__x WHERE Email__c = :ssoEmail];
        } else {
            org62User.addall(org62UserMockList);
        }
        //  List<User> usertemplist= [Select Id, name from User where email = :ssoEmail];
        if (!org62User.isEmpty()){
            if (org62User[0].Mgmt_Chain_Level_02_c__c != userSyncInfo[0].Field_Values__c){
                System.debug('### non CSG user'); 
                List<User> users = new List<User>();
                users = [SELECT Id, Email, FirstName, LastName,FederationIdentifier,org62Id__c,LastModifiedDate,IsActive from User WHERE IsActive = true AND Email =:attributes.get('email')];
                if (users.isEmpty()){
                    System.debug('### create user'); 
                    
                    String selectString = 'select Alias__c,CommunityNickname__c,LanguageLocaleKey__c,LocaleSidKey__c,TimeZoneSidKey__c,'+
                        'FirstName__c, LastName__c,Title__c,Username__c,Email__c,EmailEncodingKey__c,ExternalId,' +
                        'Street__c, City__c, State__c, PostalCode__c, Country__c,Phone__c,Business_Unit_c__c,Cost_Center_c__c,' +
                        'Department__c,IsActive__c,Mgmt_Chain_Level_02_c__c,Mgmt_Chain_Level_03_c__c,Mgmt_Chain_Level_04_c__c,Mgmt_Chain_Level_05_c__c, ' +
                        'Mgmt_Chain_Level_06_c__c,Mgmt_Chain_Level_07_c__c, Mgmt_Chain_Level_08_c__c, Mgmt_Chain_Level_09_c__c,' +
                        'FederationIdentifier__c,' +
                        'ManagerId__c,BU_c__c, Hire_Date_c__c,JobCode_c__c,JobFamily_c__c,JobGrade_c__c,JobProfile_c__c ' +
                        'from Org62_User__x WHERE Email__c =:'+ 'ssoEmail';
                    system.debug('look at the query'+ selectString);
                    List<Org62_User__x> userXList = new List<Org62_User__x>();
                    if(!Test.isRunningTest()){
                        userXList = Database.query(selectString);
                    }else{
                        userXList.addall(org62UserMockList);
                    }
                    if(!userXList.isEmpty()){
                        u = setupUser(new User(), userXList[0], true);
                        system.debug('going to insert user');
                      //  CreateNonCSGUser cruser =  new CreateNonCSGUser();
                    //    u = cruser.createUser(u);
                         insert u;
                        system.debug('insert successful');
                    }
                }
                handleUser(create, u, attributes, federationIdentifier, true);
            }
        }
        return u;
    }
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('createUser###'+ 'Id'+ samlSsoProviderId + 'CommunityId'+ communityId + + 'portalId'+  portalId+ 'federationIdentifier'+  federationIdentifier + 'Map keys set'+  attributes.keySet()+ 'Map keys values'+  attributes.values()   + 'assertion'+ assertion);
        
        User u = new User();
        u = handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        
        system.debug('Exit the class and everything looks good' + u.id);
        return u;
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('updateUser###'+ 'Id'+ samlSsoProviderId + 'CommunityId'+ communityId + + 'portalId'+  portalId+ 'federationIdentifier'+  federationIdentifier + 'Map keys set'+  attributes.keySet()+ 'Map keys values'+  attributes.values()   + 'assertion'+ assertion);
        User u ;
        if (! Test.Isrunningtest()) {
            u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
        }
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    public User setupUser(User u, Org62_User__x externalUser, Boolean ins) {
        if (ins) {
            String un = externalUser.Username__c;
            un = un.replace('@salesforce.com', '@sfservices.com');
            u.FirstName = externalUser.FirstName__c;
            u.LastName = externalUser.lastName__c;
            u.Username = un;
            u.Email = externalUser.Email__c;
            u.Alias = externalUser.Alias__c;
            u.ProfileId = [select Id from Profile where name =: 'CSG Base Profile'].Id;
            u.CommunityNickname = externalUser.CommunityNickname__c;
            u.LanguageLocaleKey = externalUser.LanguageLocaleKey__c;
            u.LocaleSidKey = externalUser.LocaleSidKey__c;
            u.TimeZoneSidKey = externalUser.TimeZoneSidKey__c;
            u.EmailEncodingKey = externalUser.EmailEncodingKey__c;
        }
        
        if (!ins && u.Email != externalUser.Email__c) {
            u.Email = externalUser.Email__c;
        }
        
        u.FederationIdentifier = externalUser.FederationIdentifier__c;
        u.Department = externalUser.Department__c;
        u.IsActive = externalUser.IsActive__c;
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
        //  u.Continuous_Service_Date__c = externalUser.Continuous_Service_Date_c__c;
        u.Phone = externalUser.Phone__c;
        //  u.Is_LOA__c = externalUser.Sick_Leave_c__c;
        //   u.Acquired_Company__c = externalUser.Acquired_Company_c__c;
        //     u.Skill_Type__c = externalUser.Skill_Type_c__c;
        
        System.debug('setup user for insert ' + ins + '::' + u);
        return u;
    }
}