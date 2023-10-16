@isTest
private class lp_PAOnboarding_SVC_Test 
{
    // Test Variables
    public static lp_Forecast_Category__c fc1;
    public static lp_Forecast_Category__c fc2 = new lp_Forecast_Category__c();
    public static lp_Forecast_Category__c fc3 = new lp_Forecast_Category__c();
    
    public static lp_Learning_Path__c lp1;
    public static lp_Learning_Path__c lp2;
    
    public static lp_Learning_Path_Milestone__c lpms1;
    public static lp_Learning_Path_Milestone__c lpms2;
    
    public static Badge__c b1;
    public static Badge__c b2;
    public static Badge__c b3;
    
    public static lp_Certificate__c c1;
    public static lp_Certificate__c c2;
    public static lp_Certificate__c c3;
    
    Account a = new Account();
   
    static testMethod void testMethod1() 
    {
        createTestData();
           
        /*    
        PA_Onboarding__c lpad = UTIL_TestFactory.launchPad(c, '012V00000008eppIAA', 100);
        lpad.Learning_Path__c = lp1.Id;
        System.debug(LoggingLevel.INFO, '$$  Insert LaunchPAd with lp1: '+lpad);
        insert lpad;
                
        lpad.Learning_Path__c = lp1.Id;
        System.debug(LoggingLevel.INFO, '$$  Update LaunchPAd back to lp1: '+lpad);
        update lpad;
        */
    
    }
    
    public static testMethod void testcheckForChangedLearningPath()
    {
        createTestData();
        
        List<PA_Onboarding__c> updatedLPADS = new List<PA_Onboarding__c>();
        Contact contact;
        
        contact = lp_UTIL_TestFactory.contact('Doe', 'John');
        PA_Onboarding__c lPad1 = lp_UTIL_TestFactory.launchPad(contact, '0123000000058Z5AAl', 70.00,lp1);
        insert lPad1;
        updatedLPADS.add(lPad1);
        
        contact = lp_UTIL_TestFactory.contact('Smith', 'Mary');
        PA_Onboarding__c lPad2 = lp_UTIL_TestFactory.launchPad(contact, '0123000000058Z5AAl', 80.00,lp2);
        insert lPad2;
        updatedLPADS.add(lPad2);
        
        //create consultant milestone
        lp_Consultant_Milestone__c cm1 = lp_UTIL_TestFactory.createConsultantMilestone(lpms1, lPad1);
        insert cm1;
        
        lp_Consultant_Milestone__c cm2 = lp_UTIL_TestFactory.createConsultantMilestone(lpms2, lPad2);
        insert cm2;
        
    	lp_PAOnboarding_SVC.checkForChangedLearningPath(updatedLPADS);
        
        
    }
    
    
    public static void createTestData()
    {
        // 1. Create Forecast Category
        fc1 = lp_UTIL_TestFactory.createForecastCategory('Forecast Category 1');    
        fc2 = lp_UTIL_TestFactory.createForecastCategory('Forecast Category 2');  
        fc3 = lp_UTIL_TestFactory.createForecastCategory('Forecast Category 3');  
        
        // 2. Create Learning Path
        lp1 = lp_UTIL_TestFactory.learningPath('Test Learning Path 1');
        lp2 = lp_UTIL_TestFactory.learningPath('Test Learning Path 2');
        
        
        // 3. Create Badges
        
        
        // 4. Create Certifications
        
        
        // 5. Create Learning Path Milestones
        lpms1 = lp_UTIL_TestFactory.learningPathMilestone(lp1, 'Milestone 1');
        lpms1.ForecastCategoryName__c = fc1.Name;
        insert lpms1;
        
        lpms2 = lp_UTIL_TestFactory.learningPathMilestone(lp1, 'Milestone 2');
        lpms2.ForecastCategoryName__c = fc2.Name;
        insert lpms2;
        
        
        
        // 6. Create Person Account
        
        
    
    }
    
}