/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 * @Ticket W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service
 * 
 * @description Test Class for the "Judge_TriggerHelper" Trigger Helper.
 *              The test class verify that the judge activation and process is correct upon approval.
 *              Upon approval, for each judge records triggered the class will assign the "PA - mentor & badge approver" permission set if needed.
 *
 *  @Ticket      - W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service.
 */
@isTest
public with sharing class Judge_TriggerHelper_TEST
{
    /**
     * Method setting up testing data
     * @name - setupData()
     * @param - NA
     * @return void
     */
    @testSetup 
    public static void setupData ()
    {
        Contact testContact = TestDataFactory.createContact();
        insert testContact;

        PA_Onboarding_Property__c testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
        insert testPaOnboardingProperty;

        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(UserInfo.getUserId(), UserInfo.getUserId(), testContact.Id);
        testPaOnboarding.Has_CTA__c = true;
        insert testPaOnboarding;

        Judge__c testJudge = TestDataFactory.createJudge(testPaOnboarding.Candidate__c, testPaOnboarding.Candidate__r.Name);
        insert testJudge;

        Judge_TriggerHelper.AssignJudgePermissionSetToUser_future(new List<Id>{UserInfo.getUserId()}, new Set<Id>{UserInfo.getUserId()});
    }

    /*
     ******************************************************************************************************************************************************
     * Test 1 - Test the flow when the judge request was approved for the first (Inactive) and the related user needs to be assigned with the
     *          "PA - mentor & badge approver" permission set.
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowJudgeApprovedRequiringPermissionSet()
     * @param       - NA
     * @return      - void
     * @description - The judge record was approved for the first time.
     *
     *                Test Expectation:
     *                      The judge record is activated.
     *                      The "Judging_Skills__c" field is updated with the values that have been approved.
     *                      The "Nine_Domain_Badges__c" field is emptied for the next time.
     *                      The "PA - mentor & badge approver" permission set is assigned to the related user.
     */
    private static testMethod void testFlowJudgeApprovedRequiringPermissionSet()
    {
        Test.startTest();
            
            Judge__c testJudge              = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            testJudge.Request_Approved__c   = true;
            testJudge.Is_Active__c          = false;
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Nine_Domain_Badges__c = 'Apex & VF';
            testJudge.Nine_Domain_Badges__c = 'Apex & Visualforce';
            update testJudge; 

            testJudge = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            system.assertEquals(testJudge.Request_Approved__c, false);
            system.assertEquals(testJudge.Is_Active__c, true);
            system.assertEquals(testJudge.Nine_Domain_Badges__c, Null);
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > system.assertEquals(testJudge.Judging_Skills__c, 'Apex & VF');
            system.assertEquals(testJudge.Judging_Skills__c, 'Apex & Visualforce');
            delete testJudge;
            
        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 2 - Test the flow when the judge request was approved but not for the first (Active), the related user does NOT need to be assigned with the
     *          "PA - mentor & badge approver" permission set.
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowJudgeApprovedNotRequiringPermissionSet()
     * @param       - NA
     * @return      - void
     * @description - The judge record was approved via approval process adding domains, the judge already existed and is already active, no need for permission set assignment.
     *
     *                Test Expectation:
     *                      The "Judging_Skills__c" field is updated with the values that have been approved.
     *                      The "Nine_Domain_Badges__c" field is emptied for the next time.
     */
    private static testMethod void testFlowJudgeApprovedNotRequiringPermissionSet()
    {
        Test.startTest();
            
            Judge__c testJudge              = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            testJudge.Request_Approved__c   = true;
            testJudge.Is_Active__c          = true;
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Judging_Skills__c     = 'Apex & VF';
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Nine_Domain_Badges__c = 'Apex & VF';
            testJudge.Judging_Skills__c     = 'Apex & Visualforce';
            testJudge.Nine_Domain_Badges__c = 'Apex & Visualforce';
            update testJudge; 

            testJudge = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            system.assertEquals(testJudge.Request_Approved__c, false);
            system.assertEquals(testJudge.Nine_Domain_Badges__c, Null);
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > system.assertEquals(testJudge.Judging_Skills__c, 'Apex & VF');
            system.assertEquals(testJudge.Judging_Skills__c, 'Apex & Visualforce');

            delete testJudge;
            
        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 3 - Test the flow when the judge request was rejected and the judge is new (Inactive).
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowNewJudgeNotApprovedNotRequiringPermissionSet()
     * @param       - NA
     * @return      - void
     * @description - The judge record was approved via approval process adding domains, the judge already existed and is already active, no need for permission set assignment.
     *
     *                Test Expectation:
     *                      The "Judging_Skills__c" field is NOT updated with the values since rejected.
     *                      The "Nine_Domain_Badges__c" field is emptied for the next time.
     */
    private static testMethod void testFlowNewJudgeNotApprovedNotRequiringPermissionSet()
    {
        Test.startTest();
            
            Judge__c testJudge              = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            testJudge.Request_Rejected__c   = true;
            testJudge.Is_Active__c          = false;
            testJudge.Judging_Skills__c     = Null;
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Nine_Domain_Badges__c = 'Apex & VF;Sharing & Security';
            testJudge.Nine_Domain_Badges__c = 'Apex & Visualforce;Sharing & Visibility';
            update testJudge; 

            testJudge = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            system.assertEquals(testJudge.Request_Rejected__c, false);
            system.assertEquals(testJudge.Is_Active__c, false);
            system.assertEquals(testJudge.Nine_Domain_Badges__c, Null);
            system.assertEquals(testJudge.Judging_Skills__c, Null);

            delete testJudge;
            
        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 4 - Test the flow when the judge request was rejected and the judge exist (Active).
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowExistingActiveJudgeNotApprovedNotRequiringPermissionSet()
     * @param       - NA
     * @return      - void
     * @description - The judge record was approved via approval process adding domains, the judge already existed and is already active, no need for permission set assignment.
     *
     *                Test Expectation:
     *                      The "Judging_Skills__c" field is NOT updated with the values since rejected.
     *                      The "Nine_Domain_Badges__c" field is emptied for the next time.
     */
    private static testMethod void testFlowExistingActiveJudgeNotApprovedNotRequiringPermissionSet()
    {
        Test.startTest();
            
            Judge__c testJudge              = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            testJudge.Request_Rejected__c   = true;
            testJudge.Is_Active__c          = true;
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Judging_Skills__c     = 'Apex & VF';
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > testJudge.Nine_Domain_Badges__c = 'Apex & VF;Sharing & Security';
            testJudge.Judging_Skills__c     = 'Apex & Visualforce';
            testJudge.Nine_Domain_Badges__c = 'Apex & Visualforce;Sharing & Visibility';
            update testJudge; 

            testJudge = [SELECT Id, User__c, Request_Approved__c, Request_Rejected__c, Is_Active__c, Judging_Skills__c, Nine_Domain_Badges__c FROM Judge__c LIMIT 1];
            system.assertEquals(testJudge.Request_Rejected__c, false);
            system.assertEquals(testJudge.Nine_Domain_Badges__c, Null);
            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch Changes > system.assertEquals(testJudge.Judging_Skills__c, 'Apex & VF');
            system.assertEquals(testJudge.Judging_Skills__c, 'Apex & Visualforce');

            delete testJudge;
            
        Test.stopTest();
    }
}