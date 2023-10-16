/**
 * @author Jonathan Cohen - Salesforce.com
 * @date   September 2016
 * @group  Services Org
 * @Ticket W-000858 : Sign-up as a 9-domain judge in LaunchPAd - self-service
 *
 * @description Controller for the "PABadgeJudgeRequest" VF Page.
 *      The controller will manage the judge request process and verify that the user requesting to be a 9 domain badge has
 *      a PA_Onbording related and that there is no request pending approval.
 *          - If there is no PA_Onboarding related -> the page will display an error message.
 *          - If there is a request pending approval -> the page will display an error message.
 *          - Otherwise the page will allow the user to choose and fill the following information:
 *              -   The domains in which he wants to be a judge.
 *              -   The region supported.
 *              -   The additional languages supported.
 *
 *      Once submitted by the user, the following validation will be applied:
 *          - The user must own every domain badge he is requesting to be a judge for.
 *          - The domain badges tenure recommended > 1 year byt not blocking.
 *              - If the validation is correct, the Judge_Sign_Up_Request__c will be inserted/updated with the selected elements.
 *                  - A success message will be displayed.
 *                  - The judge record will be submitted for approval.
 *              - Otherwise an error message will be displayed.
 *
 *          - If the user requesting to be a judge is a CTA -> there is no need to verify domain propriety neither tenure and the judge record will be submitted for approval.
 *
 *      Upon approval, the Judge record will be activated and the requesting user will receive the "PA - mentor & badge approver" permission set.
 */
@isTest
private class PABadgeJudgeRequest_TEST
{
    /*
     ******************************************************************************************************************************************************
     * Test 1 - Test the flow when the user requesting to be a judge has no PA_Onboarding record related.
     *          The controller will sent an error message and the flow can't continue.
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowWithoutPaOnboardingRelated()
     * @param       - NA
     * @return      - void
     * @description - The user requesting to be a judge has no PA_Onboarding recored related.
     *                
     *                Test Expectation: The constructor will catch the invalid flow and block the process as well as display a message to the user.
     */
    private static testMethod void testFlowWithoutPaOnboardingRelated()
    {
        Test.startTest();
            PABadgeJudgeRequest_CTRL pABadgeJudgeRequest_CTRL = new PABadgeJudgeRequest_CTRL(new ApexPages.StandardController(New Judge__C()));

            system.assertEquals(pABadgeJudgeRequest_CTRL.noErrorOnPageLoad, false);
            system.assertEquals(pABadgeJudgeRequest_CTRL.paRelatedToRequest, null);

        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 2 - Test the flow when the source is the PA_Onboarding record.
     *          The user has a PA_Onboarding record related but the request does not meet the validation requirement.
     *          For example, 1 of the reuqested domain is not owned by the requester.
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowWithPaOnboardingRelatedAndRequestNotValid()
     * @param       - NA
     * @return      - void
     * @description - The user requesting to be a judge has a PA_Onboarding recored related.
     *                The method will verify that the validation process works as expected.
     *                  - In this case, the user requested to be a judge in 2 domains.
     *                  - In addition a false domain name is selected to verify that the validation process can ingest inapropriate data.
     *
     *                Test expectation: We expect the validation process to return false and not to allow the request.
     */
    private static testMethod void testFlowWithPaOnboardingRelatedAndRequestNotValid()
    {
        setupTestingNecessaryData();
        PA_Onboarding__c testPaOnboarding = [SELECT Id, Name, Has_CTA__c FROM PA_Onboarding__c LIMIT 1];
        
        Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.PABadgeJudgeRequest'));
            System.currentPageReference().getParameters().put('paoid', testPaOnboarding.Id);
                    
            PABadgeJudgeRequest_CTRL pABadgeJudgeRequest_CTRL = new PABadgeJudgeRequest_CTRL(new ApexPages.StandardController(New Judge__C()));
            system.assertEquals(pABadgeJudgeRequest_CTRL.noErrorOnPageLoad, true);

            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & VF;Sharing & Security';
            pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & Visualforce;Sharing & Visibility';
            pABadgeJudgeRequest_CTRL.submitJudgeRequest();
            system.assertEquals(pABadgeJudgeRequest_CTRL.validateJudgeRequest(), false);

            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & VF;Sharing & Security;Invalid Name';
            pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & Visualforce;Sharing & Visibility;Invalid Name';
            pABadgeJudgeRequest_CTRL.submitJudgeRequest();
            system.assertEquals(pABadgeJudgeRequest_CTRL.validateJudgeRequest(), false);

            pABadgeJudgeRequest_CTRL.redirectBackToPaOnboardingPage();
            system.assertEquals(pABadgeJudgeRequest_CTRL.redirecBackButtontId, testPaOnboarding.Id);
        
        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 3 - Test the flow when the source is the PA_Onboarding record.
     *          The user has a PA_Onboarding record related and is a CTA but doest not own one of the requested badges.
     ******************************************************************************************************************************************************
     */

    /**
     * @name        - testFlowWithPaOnboardingRelatedAndIsCTA()
     * @param       - NA
     * @return      - void
     * @description - The user requesting to be a judge has a PA_Onboarding recored related and is a CTA.
     *                The method will verify that the validation process works as expected.
     *                  - In this case, the user requested to be a judge in 2 domains.
     *                       - The user does not own one of the domains.
     *
     *                Test expectation: We expect the validation process to return true since the user is a CTA even though the tenure is less than a year.
     */
    private static testMethod void testFlowWithPaOnboardingRelatedAndIsCTA()
    {
        setupTestingNecessaryData();

        PA_Onboarding__c testPaOnboarding   = [SELECT Id, Name, Has_CTA__c FROM PA_Onboarding__c LIMIT 1];
        testPaOnboarding.Has_CTA__c         = true;
        update testPaOnboarding;

        Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.PABadgeJudgeRequest'));
            System.currentPageReference().getParameters().put('paoid', testPaOnboarding.Id);
        
            PABadgeJudgeRequest_CTRL pABadgeJudgeRequest_CTRL = new PABadgeJudgeRequest_CTRL(new ApexPages.StandardController(New Judge__C()));
            system.assertEquals(pABadgeJudgeRequest_CTRL.noErrorOnPageLoad, true);

            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & VF;Sharing & Security';
            pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & Visualforce;Sharing & Visibility';
            pABadgeJudgeRequest_CTRL.submitJudgeRequest();

            system.assertEquals(pABadgeJudgeRequest_CTRL.validateJudgeRequest(), true);
            system.assertNotEquals(pABadgeJudgeRequest_CTRL.newJudgeRequest.Id, null);
            system.assertEquals(pABadgeJudgeRequest_CTRL.redirecBackButtontId, testPaOnboarding.Id);

        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test 4 - Test the flow when the source is the PA_Onboarding record.
     *          The user has a PA_Onboarding record related, is not a CTA and the request is valid.
     ******************************************************************************************************************************************************
    */ 

    /**
     * @name        - testFlowWithPaOnboardingRelatedAndValidRequest()
     * @param       - NA
     * @return      - void
     * @description - The user requesting to be a judge has a PA_Onboarding recored related and is NOT a CTA.
     *                The method will verify that the validation process works as expected.
     *                  - In this case, the user requested to be a judge in 1 domain.
     *                       - The user does own the domain and the domain.
     *
     *                Test expectation: We expect the validation process to return true since validation requirement are met.
     */
    private static testMethod void testFlowWithPaOnboardingRelatedAndValidRequest()
    {
        setupTestingNecessaryData();
        PA_Onboarding__c testPaOnboarding = [SELECT Id, Name, Has_CTA__c FROM PA_Onboarding__c LIMIT 1];

        Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.PABadgeJudgeRequest'));
            System.currentPageReference().getParameters().put('paoid', testPaOnboarding.Id);
        
            PABadgeJudgeRequest_CTRL pABadgeJudgeRequest_CTRL = new PABadgeJudgeRequest_CTRL(new ApexPages.StandardController(New Judge__C()));
            system.assertEquals(pABadgeJudgeRequest_CTRL.noErrorOnPageLoad, true);

            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & VF';
            pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & Visualforce';
            pABadgeJudgeRequest_CTRL.submitJudgeRequest();
            
            system.assertEquals(pABadgeJudgeRequest_CTRL.validateJudgeRequest(), true);
            system.assertNotEquals(pABadgeJudgeRequest_CTRL.newJudgeRequest.Id, null);
            system.assertEquals(pABadgeJudgeRequest_CTRL.redirecBackButtontId, testPaOnboarding.Id);

        Test.stopTest();
    }

        /*
     ******************************************************************************************************************************************************
     * Test 5 - Test the flow when the source is the Judge record.
     *          The user has a PA_Onboarding record related, is not a CTA and the request is valid.
     ******************************************************************************************************************************************************
    */ 

    /**
     * @name        - testFlowWithPaOnboardingRelatedAndValidRequest()
     * @param       - NA
     * @return      - void
     * @description - The user requesting to be a judge has a PA_Onboarding recored related and is NOT a CTA.
     *                The method will verify that the validation process works as expected.
     *                  - In this case, the user requested to be a judge in 1 domain.
     *                       - The user does own the domain and the domain.
     *
     *                Test expectation: We expect the validation process to return true since validation requirement are met.
     */
    private static testMethod void testFlowWithJudgeSourceAndValidRequest()
    {
        setupTestingNecessaryData();
        Judge__c testJudge = [SELECT Id, Name FROM Judge__c LIMIT 1];
        // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> testJudge.Nine_Domain_Badges__c = 'Apex & VF';
        testJudge.Nine_Domain_Badges__c = 'Apex & Visualforce';
        update testJudge;

        Test.startTest();
        
            PABadgeJudgeRequest_CTRL pABadgeJudgeRequest_CTRL = new PABadgeJudgeRequest_CTRL(new ApexPages.StandardController(testJudge));
            system.assertEquals(pABadgeJudgeRequest_CTRL.noErrorOnPageLoad, true);

            // Sriram Venkatraman 12/19/2017: Post Bedrock Launch change >> pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & VF';
            pABadgeJudgeRequest_CTRL.newJudgeRequest.Nine_Domain_Badges__c = 'Apex & Visualforce';
            pABadgeJudgeRequest_CTRL.submitJudgeRequest();
            
            system.assertEquals(pABadgeJudgeRequest_CTRL.validateJudgeRequest(), true);
            system.assertNotEquals(pABadgeJudgeRequest_CTRL.newJudgeRequest.Id, null);
            system.assertEquals(pABadgeJudgeRequest_CTRL.redirecBackButtontId, testJudge.Id);

        Test.stopTest();
    }

    /*
     ******************************************************************************************************************************************************
     * Test class necessary methods
     ******************************************************************************************************************************************************
    */ 

    /**
     * Method setting up testing data
     * @name - setupData()
     * @param - NA
     * @return void
     */
    private static void setupTestingNecessaryData()
    {
        Contact testContact = TestDataFactory.createContact();
        insert testContact;

        PA_Onboarding_Property__c testPaOnboardingProperty = TestDataFactory.createPaOnboardingProperty();
        insert testPaOnboardingProperty;

        PA_Onboarding__c testPaOnboarding = TestDataFactory.createPaOnboarding(UserInfo.getUserId(), UserInfo.getUserId(), testContact.Id);
        insert testPaOnboarding;

        List<Learning_Domain__c> testLearningDomain_List = TestDataFactory.create9LearningDomainBadgedOnlyInApexList(testPaOnboarding.Id);
        insert testLearningDomain_List;
        
        Judge__c testJudge = TestDataFactory.createJudge(UserInfo.getUserId(), 'Name');
        insert testJudge;
    }

    /**
     * @name        - returnlearningDomainBySkillNameMap()
     * @param       - learningDomain_List: Learning Domain List
     * @return      - Map<String, Learning_Domain__c> returnlearningDomainBySkillNameMap: A map of the learning domains mapped by their domain name.
     */
    private static Map<String, Learning_Domain__c> returnlearningDomainBySkillNameMap(List<Learning_Domain__c> learningDomain_List)
    {
        Map<String, Learning_Domain__c> learningDomainBySkillName_Map = new Map<String, Learning_Domain__c>();
        for(Learning_Domain__c learningDomain : learningDomain_List)
        {
            learningDomainBySkillName_Map.put(learningDomain.Skill__c, learningDomain);
        }
        return learningDomainBySkillName_Map;
    }
}