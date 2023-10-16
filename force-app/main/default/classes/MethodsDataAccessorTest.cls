@isTest
public with sharing class MethodsDataAccessorTest {
    public static Methods__c buildMethods(
        Id projectId,
        String completionStatus,
        Integer endDateYear
    ) {
        return new Methods__c(
            End_Date__c = Date.newInstance(endDateYear, 2, 17),
            Completion_Status__c = completionStatus,
            Method__c = MethodDataAccessorTest.buildMethod('Should Use').Id,
            PSA_Project__c = projectId
        );
    }

    @isTest
    private static void getMethodsFields_givenPSAProject_shouldReturnMethodsInfoFields() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Methods__c methods = buildMethods(project.Id, 'Complete', 2022);
        insert methods;

        Test.startTest();
        List<Methods__c> returnedMethods = new MethodsDataAccessor()
            .getMethodsByPSAProjectId(project.Id);
        Test.stopTest();

        System.assertEquals(methods.Id, returnedMethods.get(0).Id, 'should return correct Id');
    }

    @isTest
    private static void updateMethods_givenMethods_shouldUpdateInDB() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Methods__c methods = buildMethods(project.Id, 'Complete', 2022);
        insert methods;

        methods.End_Date__c = DateTime.now().date();

        Test.startTest();
        new MethodsDataAccessor().updateMethods(new List<Methods__c>{ methods });
        Test.stopTest();

        System.assertEquals(
            methods.End_Date__c,
            [SELECT End_Date__c FROM Methods__c]
            .End_Date__c,
            'should update in database'
        );
    }

    @isTest
    private static void getMethodsStatus_givenMethodsId_shouldRetrieveMethods() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;

        Methods__c methods = buildMethods(project.Id, 'Complete', 2022);
        insert methods;

        Test.startTest();
        List<Methods__c> returnedMethods = new MethodsDataAccessor()
            .getMethodsStatus(new Set<Id>{ methods.Id });
        Test.stopTest();

        System.assertEquals(1, returnedMethods.size(), 'should retrieve from db');
        System.assertEquals(methods.Id, returnedMethods[0].Id, 'should retrieve correct record from db');
    }

    @isTest
    private static void getMethodsOptions_givenPSAProject_shouldReturnMethodsInfoFields() {
        PSA_Project__c project = PSA_ProjectDataAccessorTest.buildProject();
        upsert project;
        
        Methods__c methods = buildMethods(project.Id, 'Complete', 2022);
        insert methods;

        Test.startTest();
        List<Slack.Option> methodsOptions = new MethodsDataAccessor()
            .getMethodsOptionsByProjectId(project.Id);
        Test.stopTest();

        System.assertEquals(methods.Id, methodsOptions.get(0).getValue(), 'should return correct Id');
    }

    @isTest
    private static void getMethodDropdownQuestions_givenMethod_shouldReturnMethodQuestionFields() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_Question__c mockMethodQuestion = new Method_Question__c(
            Id = MockSObjectBuilder.getMockId(Method_Question__c.getSObjectType()),
            Method__r = mockMethod
        );
        methodsDAMock.methodQuestions.add(mockMethodQuestion);


        Test.startTest();
        List<Method_Question__c> methodQuestions = new MethodsDataAccessor().getMethodDropdownQuestionsByMethodId(mockMethod.Id);
        List<Method_Question__c> mockMethodQuestions = methodsDAMock.getMethodDropdownQuestionsByMethodId(mockMethod.Id);
        Test.stopTest();

        System.assertEquals(mockMethodQuestions[0].Id, mockMethodQuestion.Id, 'should return correct Id');
    }

    @isTest
    private static void getMethodTextQuestions_givenMethod_shouldReturnMethodQuestionFields() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_Question__c mockMethodQuestion = new Method_Question__c(
            Id = MockSObjectBuilder.getMockId(Method_Question__c.getSObjectType()),
            Method__r = mockMethod
        );

        methodsDAMock.methodQuestions.add(mockMethodQuestion);


        Test.startTest();
        List<Method_Question__c> methodQuestions = new MethodsDataAccessor().getMethodTextQuestionsByMethodId(mockMethod.Id);
        List<Method_Question__c> mockMethodQuestions= methodsDAMock.getMethodTextQuestionsByMethodId(mockMethod.Id);
        Test.stopTest();

        System.assertEquals(mockMethodQuestions[0].Id, mockMethodQuestion.Id, 'should return correct Id');
    }

    @isTest
    private static void getMethodQuestions_givenMethod_shouldReturnMethodQuestionFields() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_Question__c mockMethodQuestion = new Method_Question__c(
            Id = MockSObjectBuilder.getMockId(Method_Question__c.getSObjectType()),
            Method__r = mockMethod
        );
        methodsDAMock.methodQuestions.add(mockMethodQuestion);


        Test.startTest();
        List<Method_Question__c> methodQuestions = new MethodsDataAccessor().getMethodQuestionsByMethodId(mockMethod.Id);
        List<Method_Question__c> mockMethodQuestions= methodsDAMock.getMethodQuestionsByMethodId(mockMethod.Id);
        Test.stopTest();

        System.assertEquals(mockMethodQuestions[0].Id, mockMethodQuestion.Id, 'should return correct Id');
    }

    @isTest
    private static void getMethods_givenMethod_shouldReturnMethods() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Methods__c mockMethods = new Methods__c(
            Id = MockSObjectBuilder.getMockId(Methods__c.getSObjectType()),
            Method__c = mockMethod.Id
        );
        methodsDAMock.methods.add(mockMethods);


        Test.startTest();
        List<Methods__c> methods = new MethodsDataAccessor().getMethodinSOWandDeliverable(mockMethod.Id);
        List<Methods__c> returnedMockMethods= methodsDAMock.getMethodinSOWandDeliverable(mockMethod.Id);
        Test.stopTest();

        System.assertEquals(returnedMockMethods[0].Id, mockMethods.Id, 'should return correct Id');
    }

    @isTest
    private static void addMethodQuestionAnswers_givenMethodQuestionAnswers_shouldAddMethodQuestionAnswers() {
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Method_Question_Answers__c mockMethodQuestionAnswer = new Method_Question_Answers__c();

        List<Method_Question_Answers__c> mockMethodQuestionAnswersList = new List<Method_Question_Answers__c>{mockMethodQuestionAnswer};

        Test.startTest();
        List<Method_Question_Answers__c> methodQuestionAnswers = new MethodsDataAccessor().addMethodQuestionAnswers(mockMethodQuestionAnswersList);
        List<Method_Question_Answers__c> mockMethodQuestionAnswers = methodsDAMock.addMethodQuestionAnswers(mockMethodQuestionAnswersList);
        Test.stopTest();

        System.assert(mockMethodQuestionAnswers.size() == 1, 'should add one method question answer to list');
    }

    @isTest
    private static void addMethods_givenMethods_shouldAddMethods() {
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Methods__c mockMethods = new Methods__c();

        List<Methods__c> mockMethodsList = new List<Methods__c>{mockMethods};

        Test.startTest();
        List<Methods__c> methods = new MethodsDataAccessor().addMethodsForProject(mockMethodsList);
        List<Methods__c> mockReturnedMethods = methodsDAMock.addMethodsForProject(mockMethodsList);
        Test.stopTest();

        System.assert(mockReturnedMethods.size() == 1, 'should add one method to list');
    }

    @isTest
    private static void deleteMethods_givenMethods_shouldDeleteMethods() {
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();
        MethodsDAI methodsDA = new MethodsDataAccessor();

        Methods__c mockMethods = new Methods__c();

        List<Methods__c> mockMethodsList = new List<Methods__c>{mockMethods};
        List<Methods__c> methodsList = methodsDA.addMethodsForProject(mockMethodsList);
        methodsDAMock.addMethodsForProject(mockMethodsList);

        Test.startTest();
        List<Methods__c> methods = new MethodsDataAccessor().deleteMethodFromProject(methodsList[0].Id);
        List<Methods__c> mockReturnedMethods = methodsDAMock.deleteMethodFromProject(mockMethods.Id);
        Test.stopTest();

        System.assert(methodsDAMock.deletedMethodIds.size() == 1, 'should add 1 id to list');
    }

    @isTest
    private static void getMethodsFields_givenMethodsIds_shouldGetMethodsFields() {
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();

        Methods__c mockMethods = new Methods__c(
            Id = MockSObjectBuilder.getMockId(Methods__c.getSObjectType())
        );

        Set<Id> mockMethodsSet = new Set<Id>{mockMethods.Id};

        methodsDAMock.methods.add(mockMethods);

        Test.startTest();
        List<Methods__c> methods = new MethodsDataAccessor().getMethodsByMethodsIds(mockMethodsSet);
        List<Methods__c> mockReturnedMethods = methodsDAMock.getMethodsByMethodsIds(mockMethodsSet);
        Test.stopTest();

        System.assertEquals(mockReturnedMethods[0].Id, mockMethods.Id,  'should return correct Id');
    }

    @isTest
    private static void getMethodsCountQuery_givenProjectId_shouldGetMethodsCountQuery() {
        String correctQuery = 'SELECT COUNT(Id) queryCount ' +
        'FROM Methods__c ' +
        'WHERE PSA_Project__c = \'' +
        'test' +
        '\'';

        Test.startTest();
        String returnedQuery = new MethodsDataAccessor().getMethodsCountByPSAProjectIdStringQuery('test');
        Test.stopTest();

        System.assertEquals(correctQuery, returnedQuery,  'should return correct query');
    }

    @isTest
    private static void getMethodsByPSAProjectIdStringQuery_givenProjectId_shouldGetMethodsByPSAProjectIdStringQuery() {
        String correctQuery = 'SELECT Actual_Start_Date__c, Start_Date__c, End_Date__c, Completion_Status__c, Task_Title__c, ' +
        'Method__r.Id, Method__r.Name, ' +
        'Assigned_Resource__r.Slack_User_Id__c, ' +
        'Assigned_Resource__r.CSG_Role__c, ' +
        'Assigned_Resource__r.Name, ' +
        'Assigned_Resource__r.FederationIdentifier, ' +
        'Assigned_Resource__c, ' +
        'Method__r.Tier_1__c, Method__r.Micro__c, Method__r.Small__c, Method__r.Medium__c, Method__r.Large__c, Method__r.Program__c, Method_in_SOW__c, OwnerId ' +
        'FROM Methods__c ' +
        'WHERE PSA_Project__c = \'' +
        'test' +
        '\'';

        Test.startTest();
        String returnedQuery = new MethodsDataAccessor().getMethodsByPSAProjectIdStringQuery('test');
        Test.stopTest();

        System.assertEquals(correctQuery, returnedQuery,  'should return correct query');
    }

    @isTest
    private static void getPaginatedMethodsByPSAProjectId_givenProjectIdOffSetAndItemsPerPage_shouldGetCorrectMethods() {
        MethodsDataAccessorMock methodsDAMock = new MethodsDataAccessorMock();
        PSA_ProjectDataAccessorMock projectDAMock = new PSA_ProjectDataAccessorMock();
        
        PSA_Project__c mockProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.getSObjectType())
        );

        projectDAMock.projects.add(mockProject);

        Methods__c mockMethods = new Methods__c(
            Id = MockSObjectBuilder.getMockId(Methods__c.getSObjectType()),
            PSA_Project__c = mockProject.Id
        );

        methodsDAMock.methods.add(mockMethods);

        Test.startTest();
        List<Methods__c> methods = new MethodsDataAccessor().paginatedMethodsByPSAProjectId(mockProject.Id, 0, 1);
        List<Methods__c> mockReturnedMethods = methodsDAMock.paginatedMethodsByPSAProjectId(mockProject.Id, 0, 1);
        Test.stopTest();

        System.assertEquals(mockReturnedMethods[0].Id, mockMethods.Id,  'should return correct Id');
    }

}