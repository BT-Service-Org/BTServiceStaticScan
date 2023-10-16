@isTest
public class lp_ConsultantMilestone_SVC_Test {

    
    private static void createTestData()
    {
        //Create Learning Path
        lp_Learning_Path__c lp1 = lp_UTIL_TestFactory.learningPath('Test PA Learning Path');
        
        //Create Learning Path milestones
        lp_Learning_Path_Milestone__c lpms1  = lp_UTIL_TestFactory.learningPathMilestone(lp1, 'Milestone 1');
        lp_Learning_Path_Milestone__c lpms2  = lp_UTIL_TestFactory.learningPathMilestone(lp1, 'Milestone 2');
        
        lp_Learning_Path_Milestone__c lpPAReady = lp_UTIL_TestFactory.learningPathMilestone(lp1, 'PA Ready');
        
        //Create  PA onboarding record
        Contact contact;
        
        contact = lp_UTIL_TestFactory.contact('Doe', 'John');
        PA_Onboarding__c lPad1 = lp_UTIL_TestFactory.launchPad(contact, '0123000000058Z5AAl', 70.00,lp1);
        insert lPad1;
        
        //Create consultant milestones
        lp_Consultant_Milestone__c cm1 = lp_UTIL_TestFactory.createConsultantMilestone(lpms1, lPad1);
        //Set expected completion date in past
        cm1.Expected_Completion_Date__c = System.today().addDays(-30);
        insert cm1;
        
        lp_Consultant_Milestone__c cm2 = lp_UTIL_TestFactory.createConsultantMilestone(lpms2, lPad1);
        //Set expected completion date in past
        cm2.Expected_Completion_Date__c = System.today().addDays(-10);
        insert cm2;
        
        lp_Consultant_Milestone__c cm3 = lp_UTIL_TestFactory.createConsultantMilestone(lpPAReady, lPad1);
        insert cm3;
        
    }
    
    public static testmethod void testrecalulateMiestoneByConsultant()
    {
        createTestData();
        Test.startTest();
        
        Test.stopTest();
        //Assert if cm1 date pushed by 7 days System.today().addDays(-23)
        //Assert if cm2 date pushed by 7 days System.today().addDays(-3)
        //Assert if cm3 date pushed by 14 days System.today().addDays(24)
        
    }
}