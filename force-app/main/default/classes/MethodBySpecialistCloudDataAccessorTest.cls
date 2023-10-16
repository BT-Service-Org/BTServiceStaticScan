@isTest
public with sharing class MethodBySpecialistCloudDataAccessorTest {
    @isTest
    public static void getMethodBySpecialistCloudFields_givenMethodId_shouldReturnCorrectFields(){
        MethodBySpecialistCloudDataAccessorMock methodBySpecialistCloudDAMock = new MethodBySpecialistCloudDataAccessorMock();
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_by_Specialist_Cloud__c mockMethodBySpecialistCloud = new Method_by_Specialist_Cloud__c(
            Id = MockSObjectBuilder.getMockId(Method_by_Specialist_Cloud__c.getSObjectType()),
            Method__c = mockMethod.Id
        );
        methodBySpecialistCloudDAMock.methodBySpecialistCloud.add(mockMethodBySpecialistCloud);

        Test.startTest();
        Method_by_Specialist_Cloud__c[] returnedMethodBySpecialistCloud = new MethodBySpecialistCloudDataAccessor()
            .getMethodBySpecialistCloudByMethodId(new Set<Id>{mockMethod.Id});
        Method_by_Specialist_Cloud__c[] returnedMockMethodBySpecialistCloud = methodBySpecialistCloudDAMock.getMethodBySpecialistCloudByMethodId(new Set<Id>{mockMethod.Id});
        Test.stopTest();

        System.assertEquals(mockMethodBySpecialistCloud.Id, returnedMockMethodBySpecialistCloud[0].Id, 'should return correct method by specialist cloud id');
    
    }
}