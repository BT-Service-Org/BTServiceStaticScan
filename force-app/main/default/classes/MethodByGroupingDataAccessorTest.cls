@isTest
public with sharing class MethodByGroupingDataAccessorTest {
    @isTest
    public static void getMethodByGroupingFields_givenMethodId_shouldReturnCorrectFields(){
        MethodByGroupingDataAccessorMock methodByGroupingDAMock = new MethodByGroupingDataAccessorMock();
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_by_Grouping__c mockMethodByGrouping = new Method_by_Grouping__c(
            Id = MockSObjectBuilder.getMockId(Method_by_Grouping__c.getSObjectType()),
            Method__c = mockMethod.Id
        );
        methodByGroupingDAMock.methodByGrouping.add(mockMethodByGrouping);

        Test.startTest();
        Method_by_Grouping__c[] returnedMethodByGroupings = new MethodByGroupingDataAccessor()
            .getMethodByGroupingByMethodId(new Set<Id>{mockMethod.Id});
            Method_by_Grouping__c[] returnedMockMethodByGroupings = methodByGroupingDAMock.getMethodByGroupingByMethodId(new Set<Id>{mockMethod.Id});
        Test.stopTest();

        System.assertEquals(mockMethodByGrouping.Id, returnedMockMethodByGroupings[0].Id, 'should return correct method by grouping id');
    
    }
}