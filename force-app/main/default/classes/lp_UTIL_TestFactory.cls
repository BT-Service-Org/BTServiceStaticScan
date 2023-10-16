/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class lp_UTIL_TestFactory 
{
    static boolean setUpOrg_done = false;
    
    public static void setUpOrg()
    {
        if (!setUpOrg_done)
        {
            
        }
        setUpOrg_done=true;
    }
    
    public static User createUser(String firstName, String lastName, String profile)
    {
        User u = new User();
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email     = firstName + '.' + lastname + '@gmail.com';
        u.Username  = firstName + '.' + lastname + '@gmail.com';
        u.Alias     = lastName;
        Profile p = [SELECT Id from Profile where Name = :profile LIMIT 1];
        u.ProfileId = p.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        return u;   
    }
    
    public static Account createAccount(String firstName, String lastName)
    {
        // Get RecordType for Person Account
        Account a = new Account();
        a.FirstName = firstName;
        a.LastName = lastName;
        //a.Recordtype = '';
        insert a;
        return a;
    }
    
    public static Contact contact(String lastname, String firstname)
    {
        setUpOrg();
        Contact c = new Contact();
        
        c.FirstName=firstname;
        c.LastName=lastname;        

        return c;
    }
    
    public static lp_Forecast_Category__c createForecastCategory(String categoryName)
    {
        lp_Forecast_Category__c f = new lp_Forecast_Category__c();
        f.Name = categoryName;
        insert f;
        return f;
    }
    
    public static lp_Learning_Path__c learningPath(String lpName)
    {
        setUpOrg();
        lp_Learning_Path__c lp = new lp_Learning_Path__c();
        lp.Active__c=true;
        lp.Name=lpName;
        
        return lp;
    }
    
    public static lp_Learning_Path_Milestone__c learningPathMilestone(lp_Learning_Path__c learningPath,String lpMilestoneName)
    {
        setUpOrg();
        
        lp_Learning_Path_Milestone__c milestone = new lp_Learning_Path_Milestone__c();
        milestone.Name=lpMilestoneName;
        milestone.ExpectedDaysToComplete__c=14;
        milestone.Learning_Path__c = learningPath.Id;
                
        return milestone;
    }
    
    public static lp_Learning_Path_Milestone__c createLearningPathMilestone(lp_Learning_Path__c learningPath,String lpMilestoneName, Decimal DaysToComplete)
    {
        setUpOrg();
        
        lp_Learning_Path_Milestone__c milestone = new lp_Learning_Path_Milestone__c();
        milestone.Name=lpMilestoneName;
        milestone.ExpectedDaysToComplete__c=DaysToComplete;
        milestone.Learning_Path__c = learningPath.Id;
                
        return milestone;
    }
    
    public static lp_Consultant_Milestone__c createConsultantMilestone(lp_Learning_Path_Milestone__c learningPathMilestone,PA_Onboarding__c onboardingRecord)
    {
        setUpOrg();
        
        lp_Consultant_Milestone__c consultantMilestone = new lp_Consultant_Milestone__c();
        consultantMilestone.Learning_Path_Milestone__c = learningPathMilestone.Id;
        consultantMilestone.Start_Date__c = System.today();
        consultantMilestone.Expected_Completion_Date__c = System.today().addDays(10);
       	consultantMilestone.PA_Onboarding__c = onboardingRecord.Id;
        return consultantMilestone;
        
    }
    
    public static PA_Onboarding__c launchPad(Contact contact, String recordTypeId, decimal pace, 
                                             lp_Learning_Path__c learning_path)
    {
        setUpOrg();
        PA_Onboarding__c lpad = new PA_Onboarding__c();
        lpad.Contact__c = contact.Id;
        lpad.RecordTypeId = recordTypeId; //'Program_Architect';
        lpad.Pace__c = pace;
        lpad.Program_Start_Date__c = Date.today();
        lpad.Learning_Path__c = learning_path.Id;
        
        return lpad;
    }
    

    
}