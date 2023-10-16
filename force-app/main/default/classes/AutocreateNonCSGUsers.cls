//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreateNonCSGUsers implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
   
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {  
        if(create && attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username');
        }
        if(create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        if(attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if(attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        }
        if(attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        if(attributes.containsKey('User.AboutMe')) {
            u.AboutMe = attributes.get('User.AboutMe');
        }
        if(attributes.containsKey('User.Street')) {
            u.Street = attributes.get('User.Street');
        }
        if(attributes.containsKey('User.State')) {
            u.State = attributes.get('User.State');
        }
        if(attributes.containsKey('User.City')) {
            u.City = attributes.get('User.City');
        }
        if(attributes.containsKey('User.Zip')) {
            u.PostalCode = attributes.get('User.Zip');
        }
        if(attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        if(attributes.containsKey('User.CallCenter')) {
            u.CallCenterId = attributes.get('User.CallCenter');
        }
        if(attributes.containsKey('User.Manager')) {
            u.ManagerId = attributes.get('User.Manager');
        }
        if(attributes.containsKey('User.MobilePhone')) {
            u.MobilePhone = attributes.get('User.MobilePhone');
        }
        if(attributes.containsKey('User.DelegatedApproverId')) {
            u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
        }
        if(attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        if(attributes.containsKey('User.Division')) {
            u.Division = attributes.get('User.Division');
        }
        if(attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber = attributes.get('User.EmployeeNumber');
        }
        if(attributes.containsKey('User.Extension')) {
            u.Extension = attributes.get('User.Extension');
        }
        if(attributes.containsKey('User.Fax')) {
            u.Fax = attributes.get('User.Fax');
        }
        if(attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname');
        }
        if(attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if(attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }
        String uid = UserInfo.getUserId();
        User currentUser = 
            [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        if(attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if(create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if(attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if(create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if(attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if(create) {
            String alias = '';
            if(u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if(alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if(attributes.containsKey('User.TimeZoneSidKey')) {
            u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if(create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if(attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if(create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }

        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         */
        if(attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        if(attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }
        if(attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
        }
        if(attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
            u.UserRoleId = r.Id;
        }

        //Handle custom fields here

        if(!create) {
            update(u);
        }
    }

    private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
        Contact c;
        boolean newContact = false;
        if(create) {
            if(attributes.containsKey('User.Contact')) {
            String contact = attributes.get('User.Contact');
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                u.ContactId = contact;
            } else {
                c = new Contact();
                newContact = true;
            }
        } else {
            if(attributes.containsKey('User.Contact')) {
                String contact = attributes.get('User.Contact');
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                if(u.ContactId != c.Id) {
                    throw new JitException('Cannot change User.ContactId');
                }
            } else {
                String contact = u.ContactId;
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
            }
        }
        if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }

        if(attributes.containsKey('Contact.Email')) {
            c.Email = attributes.get('Contact.Email');
        }
        if(attributes.containsKey('Contact.FirstName')) {
            c.FirstName = attributes.get('Contact.FirstName');
        }
        if(attributes.containsKey('Contact.LastName')) {
            c.LastName = attributes.get('Contact.LastName');
        }
        if(attributes.containsKey('Contact.Phone')) {
            c.Phone = attributes.get('Contact.Phone');
        }
        if(attributes.containsKey('Contact.MailingStreet')) {
            c.MailingStreet = attributes.get('Contact.MailingStreet');
        }
        if(attributes.containsKey('Contact.MailingCity')) {
            c.MailingCity = attributes.get('Contact.MailingCity');
        }
        if(attributes.containsKey('Contact.MailingState')) {
            c.MailingState = attributes.get('Contact.MailingState');
        }
        if(attributes.containsKey('Contact.MailingCountry')) {
            c.MailingCountry = attributes.get('Contact.MailingCountry');
        }
        if(attributes.containsKey('Contact.MailingPostalCode')) {
            c.MailingPostalCode = attributes.get('Contact.MailingPostalCode');
        }
        if(attributes.containsKey('Contact.OtherStreet')) {
            c.OtherStreet = attributes.get('Contact.OtherStreet');
        }
        if(attributes.containsKey('Contact.OtherCity')) {
            c.OtherCity = attributes.get('Contact.OtherCity');
        }
        if(attributes.containsKey('Contact.OtherState')) {
            c.OtherState = attributes.get('Contact.OtherState');
        }
        if(attributes.containsKey('Contact.OtherCountry')) {
            c.OtherCountry = attributes.get('Contact.OtherCountry');
        }
        if(attributes.containsKey('Contact.OtherPostalCode')) {
            c.OtherPostalCode = attributes.get('Contact.OtherPostalCode');
        }
        if(attributes.containsKey('Contact.AssistantPhone')) {
            c.AssistantPhone = attributes.get('Contact.AssistantPhone');
        }
        if(attributes.containsKey('Contact.Department')) {
            c.Department = attributes.get('Contact.Department');
        }
        if(attributes.containsKey('Contact.Description')) {
            c.Description = attributes.get('Contact.Description');
        }
        if(attributes.containsKey('Contact.Fax')) {
            c.Fax = attributes.get('Contact.Fax');
        }
        if(attributes.containsKey('Contact.HomePhone')) {
            c.HomePhone = attributes.get('Contact.HomePhone');
        }
        if(attributes.containsKey('Contact.MobilePhone')) {
            c.MobilePhone = attributes.get('Contact.MobilePhone');
        }
        if(attributes.containsKey('Contact.OtherPhone')) {
            c.OtherPhone = attributes.get('Contact.OtherPhone');
        }
        if(attributes.containsKey('Contact.Title')) {
            c.Title = attributes.get('Contact.Title');
        }
        if(attributes.containsKey('Contact.Salutation')) {
            c.Salutation = attributes.get('Contact.Salutation');
        }
        if(attributes.containsKey('Contact.LeadSource')) {
            c.LeadSource = attributes.get('Contact.LeadSource');
        }
        if(attributes.containsKey('Contact.DoNotCall')) {
            String DoNotCallVal = attributes.get('Contact.DoNotCall');
            c.DoNotCall = '1'.equals(DoNotCallVal) || Boolean.valueOf(DoNotCallVal);
        }
        if(attributes.containsKey('Contact.HasOptedOutOfEmail')) {
            String HasOptedOutOfEmailVal = attributes.get('Contact.HasOptedOutOfEmail');
            c.HasOptedOutOfEmail = '1'.equals(HasOptedOutOfEmailVal) || Boolean.valueOf(HasOptedOutOfEmailVal);
        }
        if(attributes.containsKey('Contact.HasOptedOutOfFax')) {
            String HasOptedOutOfFaxVal = attributes.get('Contact.HasOptedOutOfFax');
            c.HasOptedOutOfFax = '1'.equals(HasOptedOutOfFaxVal) || Boolean.valueOf(HasOptedOutOfFaxVal);
        }
        if(attributes.containsKey('Contact.Owner')) {
            c.OwnerId = attributes.get('Contact.Owner');
        }
        if(attributes.containsKey('Contact.AssistantName')) {
            c.AssistantName = attributes.get('Contact.AssistantName');
        }
        if(attributes.containsKey('Contact.Birthdate')) {
            c.Birthdate = Date.valueOf(attributes.get('Contact.Birthdate'));
        }
        if(newContact) {
            c.AccountId = accountId;
            insert(c);
            u.ContactId = c.Id;
        } else {
            update(c);
        }
    }

    private String handleAccount(boolean create, User u, Map<String, String> attributes) {
        Account a;
        boolean newAccount = false;
        if(create) {
            if(attributes.containsKey('User.Account')) {
                String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            } else {
                if(attributes.containsKey('User.Contact')) {
                    String contact = attributes.get('User.Contact');
                    Contact c = [SELECT AccountId FROM Contact WHERE Id=:contact];
                    String account = c.AccountId;
                    a = [SELECT Id FROM Account WHERE Id=:account];
                } else {
                    a = new Account();
                    newAccount = true;
                }
            }
        } else {
            if(attributes.containsKey('User.Account')) {
            String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            } else {
                if(attributes.containsKey('User.Contact')) {
                    String contact = attributes.get('User.Contact');
                    Contact c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                    if(u.ContactId != c.Id) {
                        throw new JitException('Cannot change User.ContactId');
                    }
                    String account = c.AccountId;
                    a = [SELECT Id FROM Account WHERE Id=:account];
                } else {
                    throw new JitException('Could not find account');
                }
            }
        }
        if(attributes.containsKey('Account.Name')) {
            a.Name = attributes.get('Account.Name');
        }
        if(attributes.containsKey('Account.AccountNumber')) {
            a.AccountNumber = attributes.get('Account.AccountNumber');
        }
        if(attributes.containsKey('Account.Owner')) {
            a.OwnerId = attributes.get('Account.Owner');
        }
        if(attributes.containsKey('Account.BillingStreet')) {
            a.BillingStreet = attributes.get('Account.BillingStreet');
        }
        if(attributes.containsKey('Account.BillingCity')) {
            a.BillingCity = attributes.get('Account.BillingCity');
        }
        if(attributes.containsKey('Account.BillingState')) {
            a.BillingState = attributes.get('Account.BillingState');
        }
        if(attributes.containsKey('Account.BillingCountry')) {
            a.BillingCountry = attributes.get('Account.BillingCountry');
        }
        if(attributes.containsKey('Account.BillingPostalCode')) {
            a.BillingPostalCode = attributes.get('Account.BillingPostalCode');
        }
        if(attributes.containsKey('Account.AnnualRevenue')) {
            a.AnnualRevenue = Integer.valueOf(attributes.get('Account.AnnualRevenue'));
        }
        if(attributes.containsKey('Account.Description')) {
            a.Description = attributes.get('Account.Description');
        }
        if(attributes.containsKey('Account.Fax')) {
            a.Fax = attributes.get('Account.Fax');
        }
        if(attributes.containsKey('Account.NumberOfEmployees')) {
            a.NumberOfEmployees = Integer.valueOf(attributes.get('Account.NumberOfEmployees'));
        }
        if(attributes.containsKey('Account.Phone')) {
            a.Phone = attributes.get('Account.Phone');
        }
        if(attributes.containsKey('Account.ShippingStreet')) {
            a.ShippingStreet = attributes.get('Account.ShippingStreet');
        }
        if(attributes.containsKey('Account.ShippingCity')) {
            a.ShippingCity = attributes.get('Account.ShippingCity');
        }
        if(attributes.containsKey('Account.ShippingState')) {
            a.ShippingState = attributes.get('Account.ShippingState');
        }
        if(attributes.containsKey('Account.ShippingCountry')) {
            a.ShippingCountry = attributes.get('Account.ShippingCountry');
        }
        if(attributes.containsKey('Account.ShippingPostalCode')) {
            a.ShippingPostalCode = attributes.get('Account.ShippingPostalCode');
        }
        if(attributes.containsKey('Account.Sic')) {
            a.Sic = attributes.get('Account.Sic');
        }
        if(attributes.containsKey('Account.TickerSymbol')) {
            a.TickerSymbol = attributes.get('Account.TickerSymbol');
        }
        if(attributes.containsKey('Account.Website')) {
            a.Website = attributes.get('Account.Website');
        }
        if(attributes.containsKey('Account.Industry')) {
            a.Industry = attributes.get('Account.Industry');
        }
        if(attributes.containsKey('Account.Ownership')) {
            a.Ownership = attributes.get('Account.Ownership');
        }
        if(attributes.containsKey('Account.Rating')) {
            a.Rating = attributes.get('Account.Rating');
        }
        if(newAccount) {
            insert(a);
        } else {
            update(a);
        }
        return a.Id;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               Map<String, List<UserSync__mdt>> config = new Map<String, List<UserSync__mdt>>();
                               List<UserSync__mdt> userSyncInfo = [select Field_API_name__c, Field_Values__c,Type__c FROM UserSync__mdt where Active__c = true AND Field_API_name__c LIKE '%Level_02%'];
                               System.debug('### AES attributes '+attributes);
                               /*System.debug('### AES attributes '+attributes.get('userId')); 
                               UserContactUtil.doNotExecuteTrigger = true; 
                               List<User__x> org62User = new List<User__x>();
                               org62User = [SELECT Mgmt_Chain_Level_02_c__c FROM User__x WHERE ExternalId =:attributes.get('userId')];
                               if(!org62User.isEmpty()){
                                   if(org62User[0].Mgmt_Chain_Level_02_c__c != userSyncInfo[0].Field_Values__c){
                                       System.debug('### non CSG user'); 
                                       List<User> users = new List<User>();
                                       users = [select Id, Email, FirstName, LastName,FederationIdentifier,org62Id__c,LastModifiedDate,IsActive from User WHERE IsActive = true AND org62Id__c =:attributes.get('userId')];
                                       if(users.isEmpty()){
                                           System.debug('### create user'); 
                                           String selectString = 'select Alias__c,CommunityNickname__c,LanguageLocaleKey__c,LocaleSidKey__c,TimeZoneSidKey__c,'+
                                               'FirstName__c, LastName__c,Title__c,Username__c,Email__c,EmailEncodingKey__c,ExternalId,Support_Subgroup_c__c,' +
                                               'Street__c, City__c, State__c, PostalCode__c, Country__c,Phone__c,Business_Unit_c__c,Cost_Center_c__c,' +
                                               'Department__c,IsActive__c,Mgmt_Chain_Level_02_c__c,Mgmt_Chain_Level_03_c__c,Mgmt_Chain_Level_04_c__c,Mgmt_Chain_Level_05_c__c, ' +
                                               'Mgmt_Chain_Level_06_c__c,Mgmt_Chain_Level_07_c__c, Mgmt_Chain_Level_08_c__c, Mgmt_Chain_Level_09_c__c,' +
                                               'Acquired_Company_c__c,Sick_Leave_c__c,Continuous_Service_Date_c__c ,FederationIdentifier__c,' +
                                               'ManagerId__c,BU_c__c, Hire_Date_c__c,JobCode_c__c,JobFamily_c__c,JobGrade_c__c,Skill_Type_c__c,JobProfile_c__c ' +
                                               'from User__x WHERE externalId =:'+attributes.get('userId');
                                                List<User__x> userXList = Database.query(selectString);
                                               if(!userXList.isEmpty()){
                                                   User us = setupUser(new User(), userXList[0], true);
                                                   insert us;
                                               }
                                       }
                                       /*if(communityId != null || portalId != null) {
                                           String account = handleAccount(create, u, attributes);
                                           handleContact(create, account, u, attributes);
                                           handleUser(create, u, attributes, federationIdentifier, false);
                                       } else {
                                           handleUser(create, u, attributes, federationIdentifier, true);
                                       }*/
                                   //}
                               //}
    }
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
    public User setupUser(User u, User__x externalUser, Boolean ins) {
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
            u.Support_Subgroup__c = externalUser.Support_Subgroup_c__c; //GR:Nov 26, 2018 to map specialists
            u.JobGrade__c = externalUser.JobGrade_c__c;
            u.Street = externalUser.Street__c;
            u.City = externalUser.City__c;
            u.State = externalUser.State__c;
            u.PostalCode = externalUser.PostalCode__c;
            u.Country = externalUser.Country__c;
            u.Org62Id__c = externalUser.ExternalId;
            u.Continuous_Service_Date__c = externalUser.Continuous_Service_Date_c__c;
            u.Phone = externalUser.Phone__c;
            u.Is_LOA__c = externalUser.Sick_Leave_c__c;
            u.Acquired_Company__c = externalUser.Acquired_Company_c__c;
            u.Skill_Type__c = externalUser.Skill_Type_c__c;
            
            System.debug('setup user for insert ' + ins + '::' + u);
            return u;
        }
}