//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreateNonCSGStationUsers implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
   // @TestVisible private static  List<Org62_User__x> org62UserMockList  = new  List<Org62_User__x>(); 
    private void handleUser(boolean create, User u, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {  
        
        system.debug('lets see what we have'+ 'Create'+ create + 'User'+ u  + 'Map keys'+  attributes.keySet()+ 'Map keys'+  attributes.values() + 'federation identifier' + federationIdentifier + 'isStandard'+ isStandard);
        
        system.debug('see User' + create + attributes.get('username') + 'fed identifier' + attributes.get('User.FederationIdentifier')+ attributes.get('User.Email') + attributes.get('User.LastName'));
        
        system.debug('See actula User here'+ User.Email + User.firstName +User.lastName);
       
       if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } 
        
        if (create){
        
             if(u.Email!=null) {
                 
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
        handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
        
        system.debug('Exit the class and everything looks good' + u.lastName);
        return u;
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        system.debug('updateUser###'+ 'User Id'+ userId+ 'Id'+ samlSsoProviderId + 'CommunityId'+ communityId + + 'portalId'+  portalId+ 'federationIdentifier'+  federationIdentifier + 'Map keys set'+  attributes.keySet()+ 'Map keys values'+  attributes.values()   + 'assertion'+ assertion);
        for(String str : attributes.keySet()){
            system.debug('what we have in Map'+ str +attributes.get(str));
        }
        
        
           
         User u = [SELECT Id, FirstName,LastName,federationIdentifier,  Email FROM User WHERE federationIdentifier = :federationIdentifier ];
          
          
        
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    
}