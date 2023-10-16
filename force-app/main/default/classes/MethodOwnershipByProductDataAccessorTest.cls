@isTest
public with sharing class MethodOwnershipByProductDataAccessorTest {
    @isTest
    public static void getMethodOwnershipByProductFields_givenMethodId_shouldReturnCorrectFields(){
        MethodOwnershipByProductDataAccessorMock methodOwnershipByProductDAMock = new MethodOwnershipByProductDataAccessorMock();
        MethodDataAccessorMock methodDAMock = new MethodDataAccessorMock();

        Method__c mockMethod = new Method__c(
            Id = MockSObjectBuilder.getMockId(Method__c.getSObjectType())
        );
        methodDAMock.methods.add(mockMethod);

        Method_Ownership_by_Product__c mockMethodOwnershipByProduct = new Method_Ownership_by_Product__c(
            Id = MockSObjectBuilder.getMockId(Method_Ownership_by_Product__c.getSObjectType()),
            Method__c = mockMethod.Id
        );
        methodOwnershipByProductDAMock.methodOwnershipByProduct.add(mockMethodOwnershipByProduct);

        Test.startTest();
        Method_Ownership_by_Product__c[] returnedMethodOwnershipByProduct = new MethodOwnershipByProductDataAccessor()
            .getMethodOwnershipByProductByMethodId(new Set<Id>{mockMethod.Id});
            Method_Ownership_by_Product__c[] returnedMockMethodOwnershipByProduct = methodOwnershipByProductDAMock.getMethodOwnershipByProductByMethodId(new Set<Id>{mockMethod.Id});
        Test.stopTest();

        System.assertEquals(mockMethodOwnershipByProduct.Id, returnedMockMethodOwnershipByProduct[0].Id, 'should return correct method ownership by product id');
    
    }
}