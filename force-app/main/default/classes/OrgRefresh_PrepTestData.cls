@IsTest
public class OrgRefresh_PrepTestData {
    public static Org_Refresh_Profile__c createRefreshProfileData(OrgRefresh_AuthFlows authFlow) {
        Org_Refresh_Profile__c orgRefreshProf=new Org_Refresh_Profile__c();
        //orgRefreshProf.Name='Test Class Created Org';
        orgRefreshProf.Name='CertOrg_Cert';
        orgRefreshProf.Endpoint__c='https://test.com';
        orgRefreshProf.Consumer_Key__c='aaaaa';
        orgRefreshProf.Consumer_Secret__c='bbb';
                    

        if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_WEBFLOW) || 
            OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN)){
            orgRefreshProf.UserNamePwd_Flow__c=false;
            orgRefreshProf.Callback_URL__c='https://test.callback.com';
            if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN)){
                orgRefreshProf.Refresh_Token__c='test_refresh_token';
            }
        }
        else{
            orgRefreshProf.UserNamePwd_Flow__c=true;
            orgRefreshProf.username__c='testclass@username.com';
        }
        orgRefreshProf.Auto_Refresh__c=true;
        orgRefreshProf.Query__c='select Id from Account';
        
        return orgRefreshProf;

    }

    public static PA_Onboarding_Property__c createPAOnboardingSelectedOrg(String selectedOrgName){
        PA_Onboarding_Property__c paOnboarding=new PA_Onboarding_Property__c();
        paOnboarding.Name='selectedOrg';
        paOnboarding.Key__c='selectedOrg';
        paOnboarding.Value__c=selectedOrgName;
        return paOnboarding;
    }

    public static Org_Refresh_Profile__c createRefreshProfileDataWithStartAndEnd(OrgRefresh_AuthFlows authFlow) {
        Org_Refresh_Profile__c orgRefreshProf=new Org_Refresh_Profile__c();
        orgRefreshProf.Name='CertOrg_Cert';
        orgRefreshProf.Endpoint__c='https://test.com';
        orgRefreshProf.Consumer_Key__c='aaaaa';
        orgRefreshProf.Consumer_Secret__c='bbb';
                    

        if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_WEBFLOW) || 
            OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN)){
            orgRefreshProf.UserNamePwd_Flow__c=false;
            orgRefreshProf.Callback_URL__c='https://test.callback.com';
            if(OrgRefresh_QueryUtils.validateEnum(authflow, OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN)){
                orgRefreshProf.Refresh_Token__c='test_refresh_token';
            }
        }
        else{
            orgRefreshProf.UserNamePwd_Flow__c=true;
            orgRefreshProf.username__c='testclass@username.com';
        }
        orgRefreshProf.Auto_Refresh__c=false;
        orgRefreshProf.Start_Date__c=Date.newInstance(2014,1,1);
        orgRefreshProf.End_Date__c=Date.newInstance(2014,1,5);

        orgRefreshProf.Query__c='select Id from Account where Name=\'test\'';
        
        return orgRefreshProf;

    }

    public static void createPAOnboardingandRelated(String username,String email){
       //create user or candidate
      // This code runs as the system user
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       /*
       * UsertoContactTrigger Trigger expect an account to be there. So creating an account to avoid test class error.
       */
      
      /*User u = new User(Alias = 'standt', Email=email, 
      EmailEncodingKey='UTF-8', LastName=username, LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName=email);
      //create user.
      insert u;*/

// create mentor to tie user to, which must have an email!

/*  Contact mentorInstance = new Contact(); // CJT added mentor so records can be created for certification
        mentorInstance.LastName='Mentor-'+username;
        mentorInstance.email='mentor-'+email;
        insert mentorInstance;*/
        
        Account SFDCAcct = new Account(name='Salesforce.com'); // CJT Added so can create mentor User
        insert SFDCAcct;
        
        List<Community_Rewards_Program__c> cp = [SELECT Id, name from Community_Rewards_Program__c where name='Current FY15'];
        if (cp.size() == 0) {
            Community_Rewards_Program__c progc = new Community_Rewards_Program__c(name='Current FY15');
            insert progc;
            List<Community_Rewards_Config__c> c = [SELECT Id, name, value__c from Community_Rewards_Config__c where name='CURRENT_REWARDS_PROGRAM'];
            if (c.size() == 0) {
                Community_Rewards_Config__c configc = new Community_Rewards_Config__c(name='CURRENT_REWARDS_PROGRAM', value__c=progc.Id);
                insert configc;
            } else {
                c[0].value__c = progc.Id;
                update c[0];
            }
        }
        
        List<Profile> ps = [select id, name from Profile where name = 'Standard User'];

        User mentorUser = new User(); // CJT added mentor so records can be created for certification
        mentorUser.LastName='Mentor'+username;
        mentorUser.email = 'mentor-'+email;
        mentorUser.Username = 'mentor-'+email;
        mentorUser.Alias = 'M-tcu'+username.right(1);
        mentorUser.CommunityNickname = 'M-tcu'+username.right(1);
        mentorUser.TimeZoneSidKey = 'America/Los_Angeles';
            mentorUser.LocaleSidKey = 'en_US';
            mentorUser.EmailEncodingKey = 'UTF-8';
            mentorUser.ProfileId = ps[0].Id;
            mentorUser.LanguageLocaleKey = 'en_US';
        insert mentorUser;

      //create related contact CJT added mentor
      Contact contactInstance=new Contact();
      contactInstance.LastName=username;
      contactInstance.email=email;
    //  contactInstance.Mentor__c=mentorInstance.id;
      insert contactInstance;

      //create PA onboarding template property.
      PA_Onboarding_Property__c paOnboardingProperty=new PA_Onboarding_Property__c();
      paOnboardingProperty.name='Template PA Onboarding Id';
      paOnboardingProperty.Key__c='Template PA Onboarding Id';
      paOnboardingProperty.Value__c=contactInstance.Id;
      insert paOnboardingProperty;
 
      PA_Onboarding__c paOnboarding=new PA_Onboarding__c();
      paOnboarding.Name='PA - ' + username;
      //paOnboarding.Candidate__c=u.id;
      paOnboarding.Contact__c=contactInstance.id;
      paOnboarding.Program_Start_Date__c=System.today();
        paOnboarding.Program__c = 'Accelerated Onboarding'; //CJT Added to ensure test contacts are found in query
        paOnboarding.Mentor__c=mentorUser.id; // CJT Added to ensure certification data can be entered with required field mentor_email__c
      insert paOnboarding;

    }
}