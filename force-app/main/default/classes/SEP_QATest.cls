@isTest(SeeAllData = false)
private class SEP_QATest {
    @testSetup static void setupTestData() {
        System.debug('TEST --- Started creating test data...');
        // Create Account and Opportunity record
        Account accountWithExtId = new Account(ExternalId__c = 'TESTACCOUNT001');
        Account account = new Account(
            Name = 'Test Account',
            ExternalId__c = 'TESTACCOUNT001'
        );
        Opportunity opportunityWithExtId = new Opportunity(Org62_Id__c = 'TESTOPPORTUNITY001');
        Opportunity opportunity = new Opportunity(
            Account = accountWithExtId,
            Name = 'Test Opportunity',
            StageName = '01 - Identifying an Opportunity',
            CloseDate = Date.today().addDays(30),
            Org62_Id__c = 'TESTOPPORTUNITY001'
        );
        // Create SEP_Estimate__c record
        SEP_Estimate__c estimate = new SEP_Estimate__c(
            Name = 'Test Estimate',
            SEP_Engagement_Type__c = 'B  - Dedicated Architect',
            Opportunity__r = opportunityWithExtId,
            Description__c = 'This is a test record'
        );
        // Create SEP_Domain__c records
        List<SEP_Domain__c> domainsWithExtId = new List<SEP_Domain__c>{
            new SEP_Domain__c(
                ExternalId__c = 'TEST001'
            ),
            new SEP_Domain__c(
                ExternalId__c = 'TESTD002'
            )
        };
        List<SEP_Domain__c> domains = new List<SEP_Domain__c>{
            new SEP_Domain__c(
                Name = 'Test Sales Cloud',
                Sequence__c = 51,
                ExternalId__c = 'TEST001'
            ),
            new SEP_Domain__c(
                Name = 'Test Service Cloud',
                Sequence__c = 52,
                ExternalId__c = 'TESTD002'
            ),
            new SEP_Domain__c(
                Name = 'Test Overall Engagement Scope',
                Sequence__c = 53,
                ExternalId__c = 'TESTD003'
            )
        };
        // Create SEP_Capability__c records
        List<SEP_Capability__c> capabilitiesWithExtId = new List<SEP_Capability__c>();
        for(Integer i = 1; i <= 6; i++) {
            capabilitiesWithExtId.add(
                new SEP_Capability__c(
                    ExternalId__c = 'TESTC00' + String.valueOf(i)
                )
            );
        }
        List<SEP_Capability__c> capabilities = new List<SEP_Capability__c>();
        Integer j = 1;
        for(SEP_Domain__c domain : domainsWithExtId) {
            for(Integer i = 1; i <= 3; i++) {
                SEP_Capability__c capability = new SEP_Capability__c(
                    Name = 'Test 0' + String.valueOf(j),
                    ExternalId__c = 'TESTC00' + String.valueOf(j),
                    Description__c = 'Test records created by the test class',
                    Sequence__c = 100 + j
                );
                capability.SEP_Domain__r = domain;
                capabilities.add(capability);
                j++;
            }
        }
        // Create SEP_Question_Answers__c records
        List<SEP_Question_Answers__c> questionAnswers = new List<SEP_Question_Answers__c>();
        Integer q = 1;
        for(SEP_Capability__c capability : capabilitiesWithExtId) {
            for(Integer i = 1; i <= 3; i++) {
                SEP_Question_Answers__c questionAnswer = new SEP_Question_Answers__c(
                    Name = 'Test Question 0' + String.valueOf(q),
                    Sequence__c = 90000 + q,
                    Query__c = 'Test Question 00' + String.valueOf(q),
                    Answer_1__c = 'Not Applicable',
                    Answer_2__c = 'Unknown',
                    Answer_3__c = 'Answer A',
                    Answer_4__c = 'Answer B',
                    Answer_5__c = 'Answer C',
                    FP1__c = 0,
                    FP2__c = 10,
                    FP3__c = 20,
                    FP4__c = 30,
                    FP5__c = 45
                );
                questionAnswer.SEP_Capability__r = capability;
                questionAnswers.add(questionAnswer);
                q++;
            }
        }
        // Add all objects records in the list of sObject
        List<SObject> recordsToInsert = new List<SObject>{account, opportunity, estimate};
        recordsToInsert.addAll(domains);
        recordsToInsert.addAll(capabilities);
        recordsToInsert.addAll(questionAnswers);
        // Insert all objects records at once
        insert recordsToInsert;
        System.debug(domains);
        System.debug(capabilities);
        System.debug(questionAnswers);
    }

    @isTest static void createStreamAssessmentTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        Boolean isInsert = true;
        Test.startTest();
        String result = SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false,
            'Failed to create Stream Assessment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'false', 
            'Error occured, while creating Stream Assessment records!'
        );
    }

    @isTest static void createStreamAssessmentWithNullEstimateTest() {
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        Boolean isInsert = true;
        Test.startTest();
        String result = SEP_QA.createStreamAssessment(assessment, null, null, isInsert);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false, 
            'Failed to create Stream Assessment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'true', 
            'Error occured, while creating Stream Assessment records!'
        );
    }

    @isTest static void createStreamAssessmentWithBlankStreamAssessmentTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = false;
        Test.startTest();
        String result = SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false, 
            'Failed to create Stream Assessment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'true', 
            'Error occured, while creating Stream Assessment records!'
        );
    }

    @isTest static void createStreamAssessmentWithMaxStreamsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        List<SEP_Stream_Assessment__c> streams = new List<SEP_Stream_Assessment__c>();
        for(Integer i = 1; i <= 11; i++) {
            streams.add(
                new SEP_Stream_Assessment__c(
                    Name = 'Test Assessment 0' + String.valueOf(i),
                    Estimate__c = estimate.Id,
                    SEP_Estimate_Name__c = estimate.Name,
                    Duration__c = 10
                )
            );
        }
        insert streams;
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment 01');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        String result = SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false, 
            'Failed to create Stream Assessment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'true', 
            'Error occured, while creating Stream Assessment records!'
        );
    }
    @isTest static void createStreamAssessmentWithDuplicateStreamTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        SEP_Stream_Assessment__c streamAssessment = new SEP_Stream_Assessment__c(
            Name = 'Test Assessment 01',
            Estimate__c = estimate.Id,
            SEP_Estimate_Name__c = estimate.Name,
            Duration__c = 10
        );
        insert streamAssessment;
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment 01');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        String result = SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false, 
            'Failed to create Stream Assessment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'true', 
            'Error occured, while creating Stream Assessment records!'
        );
    }

    @isTest static void getActiveDomainsTest() {
        List<SEP_Domain__c> domains = SEP_QA.getActiveDomains();
        System.assert(
            domains.size() > 0, 
            'Failed to fetch active domains!'
        );
    }

    @isTest static void getCocPDTest() {
        Double result = SEP_QA.getCocPD(25, '');
        System.assert(
            result != null, 
            'Failed to fetch CocPD!'
        );
    }

    @isTest static void getLinearPDTest() {
        Double result = SEP_QA.getLinearPD(25);
        System.assert(
            result != null, 
            'Failed to fetch LinearPD!'
        );
    }

    @isTest static void getSlimPDTest() {
        Double result = SEP_QA.getSlimPD(25, 7, '');
        System.assert(
            result != null, 
            'Failed to fetch SlimPD!'
        );
    }

    @isTest static void getSepQA_DetailsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Domain2Assesment__c domain2Assessment = [
            SELECT Id, Name, SEP_Stream_Assessment__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
            LIMIT 1
        ];
        List<SEP_QA2Capability__c> results = SEP_QA.getSepQA_Details(domain2Assessment.Id);
        Test.stopTest();
        System.assert(
            results.size() > 0, 
            'Failed to fetch QA2Capability records!'
        );
    }
    
    @isTest static void getCapaFP4DomainTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Domain2Assesment__c domain2Assessment = [
            SELECT Id, Name, SEP_Stream_Assessment__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
            LIMIT 1
        ];
        List<SEP_Capability2Domain__c> results = SEP_QA.getCapaFP4Domain(domain2Assessment.Id);
        Test.stopTest();
        System.assert(
            results.size() > 0, 
            'Failed to fetch Capability2Domain records!'
        );
    }

    @isTest static void getRelatedDomains4SameAssessmentTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Domain2Assesment__c domain2Assessment = [
            SELECT Id, Name, SEP_Stream_Assessment__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
            LIMIT 1
        ];
        List<SEP_Domain2Assesment__c> results = SEP_QA.getRelatedDomains4SameAssessment(domain2Assessment.Id);
        Test.stopTest();
        System.assert(
            results.size() > 0, 
            'Failed to fetch Domain2Assesment records!'
        );
    }

    @isTest static void getCompletionProgressDataTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Domain2Assesment__c domain2Assessment = [
            SELECT Id, Name, SEP_Stream_Assessment__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
            LIMIT 1
        ];
        List<Integer> results = SEP_QA.getCompletionProgressData(domain2Assessment.Id);
        Test.stopTest();
        System.assert(
            results.size() > 0, 
            'Failed to fetch completion progress data!'
        );
    }

    @isTest static void updateAssessmentTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Domain2Assesment__c domain2Assessment = [
            SELECT Id, Name, SEP_Stream_Assessment__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
            LIMIT 1
        ];
        List<SEP_QA2Capability__c> qA2Capabilities = [SELECT Id, Selected_Answer__c, Question_Note__c FROM SEP_QA2Capability__c LIMIT 10];
        SEP_QA.updateAssessment(domain2Assessment.Id, qA2Capabilities);
        Test.stopTest();
    }

    @isTest static void getStreamsNdDomain2AssessmentsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        Integer domain2AssessmentSize = [
            SELECT COUNT() 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
        ];
        List<Map<String, Object>> results = SEP_QA.getStreamsNdDomain2Assessments(estimate.Id);
        Test.stopTest();
        System.assert(
            results.size() == domain2AssessmentSize, 
            'Failed to fetch Domain2Assesment records!'
        );
    }

    @isTest static void getActiveAssessmentDomainsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Stream_Assessment__c streamAssessment = [
            SELECT Id, Name FROM SEP_Stream_Assessment__c WHERE Estimate__c = :estimate.Id LIMIT 1
        ];
        Integer domain2AssessmentSize = [
            SELECT COUNT() 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id AND SEP_Stream_Assessment__c = :streamAssessment.Id
        ];
        List<SEP_Domain2Assesment__c> results = SEP_QA.getActiveAssessmentDomains(estimate.Id, streamAssessment.Id);
        Test.stopTest();
        System.assert(
            results.size() == domain2AssessmentSize, 
            'Failed to fetch active Domain2Assesment records, result size: ' + results.size()
        );
    }

    @isTest static void getArchivedAssessmentDomainsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        SEP_Stream_Assessment__c streamAssessment = [
            SELECT Id, Name FROM SEP_Stream_Assessment__c WHERE Estimate__c = :estimate.Id LIMIT 1
        ];
        List<SEP_Domain2Assesment__c> results = SEP_QA.getArchivedAssessmentDomains(estimate.Id, streamAssessment.Id);
        Test.stopTest();
        System.assert(
            results == null, 
            'Failed to fetch archive Domain2Assesment records!'
        );
    }

    @isTest static void updateAssessmentDomainsTest() {
        SEP_Estimate__c estimate = [SELECT Id, Name FROM SEP_Estimate__c];
        List<SEP_Domain__c> domains = [SELECT Id, Name, Sequence__c FROM SEP_Domain__c];
        // Setup test data for the test method parameter
        Map<String, String> assessment = new Map<String, String>();
        assessment.put('streamName', 'Test Assessment');
        assessment.put('overallEngScopeId', domains[2].Id);
        assessment.put('selStreamAssId', '');
        List<SEP_Domain__c> selDomains = domains;
        // Test for the add domain scenario
        Boolean isInsert = true;
        Test.startTest();
        SEP_QA.createStreamAssessment(assessment, estimate, selDomains, isInsert);
        List<SEP_Domain2Assesment__c> domain2Assessments = [
            SELECT Id, isActive__c 
            FROM SEP_Domain2Assesment__c 
            WHERE SEP_Stream_Assessment__r.Estimate__c = :estimate.Id
        ];
        String result = SEP_QA.updateAssessmentDomains(domain2Assessments);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false, 
            'Failed to update Domain2Assesment records!'
        );
        System.assert(
            resultObj.get('isError').toString() == 'false', 
            'Error occured, while updating Domain2Assesment records!'
        );
    }

    @isTest static void updateAssessmentDomainsWithNullTest() {
        Test.startTest();
        String result = SEP_QA.updateAssessmentDomains(null);
        Test.stopTest();
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(
            String.isEmpty(resultObj.get('message').toString()) == false
        );
        System.assert(
            resultObj.get('isError').toString() == 'true'
        );
    }

    @isTest static void getMethodBreakdownTest() {
        SEP_Method_Breakdown__mdt result = SEP_QA.getMethodBreakdown('Standard');
    }

    @isTest static void getOverallEngagementScopeIdTest() {
        String result = SEP_QA.getOverallEngagementScopeId();
    }
}