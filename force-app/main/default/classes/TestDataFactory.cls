/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 *
 * @description Class used to create Object records for Test Classes purpuse.
 */
public with sharing class TestDataFactory
{      
    /**
     *  Method to create a Contact.
     *  @name   - createContact()
     *  @description - createContact() 
     *  @return - Contact.
     **/
    public static Contact createContact()
    {
        Contact contact     = new Contact();
        contact.LastName    = 'lastNAme';
        contact.FirstName   = 'firstNAme';
        return contact;
    }

    /**
     *  Method to create a PA_Onboarding.
     *  @name   - createPaOnboarding()
     *  @description - createPaOnboarding()
     *  @param  candidateId - The user related to the PA_Onboarding.
     *  @param  mentorId - The PA_Onboarding mentor.
     *  @param  contactId - The contact related to the PA_Onboarding.
     *  @return - PA_Onboarding__c.
     **/
    public static PA_Onboarding__c createPaOnboarding(Id candidateId, Id mentorId, Id contactId)
    {
        PA_Onboarding__c paOnboarding       = new PA_Onboarding__c();
        paOnboarding.Mentor__c              = mentorId;
        paOnboarding.Contact__c             = contactId;
        paOnboarding.Candidate__c           = candidateId;
        paOnboarding.Program_Start_Date__c  = Date.Today();
        return paOnboarding;
    }

    /**
     *  Method to create a PA_Onboarding_Property__c.
     *  @name   - createPaOnboardingProperty()
     *  @description - createPaOnboardingProperty()
     *  @return - PA_Onboarding_Property__c.
     **/
    public static PA_Onboarding_Property__c createPaOnboardingProperty()
    {
        PA_Onboarding_Property__c paOnboardingProperty  = new PA_Onboarding_Property__c();
        paOnboardingProperty.Name                       = 'Template PA Onboarding Id';
        paOnboardingProperty.Key__c                     = 'Template PA Onboarding Id';
        paOnboardingProperty.Value__c                   = '';
        return paOnboardingProperty;
    }

    /**
     *  Method to create a judge.
     *  @name   - createJudge()
     *  @description - createJudge
     *  @param  userId - Id.
     *  @param  userName - String
     *  @return - Judge__c.
     **/
    public static Judge__c createJudge(Id userId, String userName)
    {
        Judge__c judge                  = new Judge__c();
        judge.Is_Active__c              = false;
        judge.Name                      = userName;
        judge.Supported_Regions__c      = 'EMEA';
        judge.Additional_Languages__c   = 'French';
        // Sriram Venkatraman 12/19/2017: Post Bedrock change > judge.Judging_Skills__c         = 'Apex & VF';
        judge.Judging_Skills__c         = 'Apex & Visualforce';
        judge.User__c                   = userId;
        return judge;
    }

    /**
     *  Method to create the 9 learning domain list.
     *  @name   - createLearningDomain()
     *  @description - createLearningDomain
     *  @param  paOnboardingId - The PA_Onboarding related to the learning domains.
     *  @return - List<Learning_Domain__c>.
     **/
    public static List<Learning_Domain__c> create9LearningDomainBadgedOnlyInApexList(Id paOnboardingId)
    {
        // Sriram Venkatraman 12/19/2017: Post Bedrock change > List<String> learningDomainSkillsName       = new List<String>{ 'Application Design', 'Sharing & Security', 'Apex & VF', 'Integration', 'Single Sign On', 'Large Data Volume', 'Communities & Sites', 'Change Management', 'Mobile'};
        List<String> learningDomainSkillsName = new List<String>{'Application Design', 'Integration Architecture', 'Development Lifecycle & Deployment', 'Identity & Access Management', 'Sharing & Visibility', 'Communities Architecture', 'Apex & Visualforce', 'Data Architecture & Management', 'Mobile Strategy Architecture', 'Analytics Architecture', 'Marketing Cloud'};        
        List<Learning_Domain__c> learningDomainList = new List<Learning_Domain__c>();
        
        for(String domainSkillName : learningDomainSkillsName)
        {
            // Sriram Venkatraman 12/19/2017: Post Bedrock change > if(domainSkillName == 'Apex & VF'){
            if(domainSkillName == 'Apex & Visualforce'){
                learningDomainList.add(createLearningDomain(domainSkillName, paOnboardingId, 'Badged'));
            }
            else{
                learningDomainList.add(createLearningDomain(domainSkillName, paOnboardingId, 'Not Badged'));
            }
        }
        return learningDomainList;
    }

    /**
     *  Method to create a learning domain.
     *  @name   - createLearningDomain()
     *  @description  - createLearningDomain
     *  @param   domainName -  The judge sign up request related.
     *  @param   paOnboardingId - The PA_Onboarding related to the learning domain.
     *  @param   status - String
     *  @return  Learning_Domain__c.
     **/
    public static Learning_Domain__c createLearningDomain(String domainName, Id paOnboardingId, String status)
    {
        Learning_Domain__c learningDomain   = new Learning_Domain__c();
        learningDomain.PA_Onboarding__c     = paOnboardingId;
        learningDomain.Skill__c             = domainName;
        learningDomain.Status__c            = status;
        return learningDomain;
    }
    /**
     * 
     *  @name   - createUser()
     *  @description  - createUser
     *  @param   Profile -  String
     *  @param   lastname - String
     *  @return  : User
     **/
    
        public static User createUser(String profile,String lastname) {
        String hostname = '@sfservices.com.qa';//swap out for prod
        Profile p = [SELECT Id FROM Profile WHERE Name=:profile];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User testUser = new User( 
            Alias = uid,
            Email= uid + hostname, 
            EmailEncodingKey='UTF-8',
            LastName= lastname,
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York',
            UserName= uid + hostname
        );
        insert testUser;
        return testUser;
    }
}