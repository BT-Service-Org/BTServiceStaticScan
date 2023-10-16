@isTest
public with sharing class MethodDataAccessorTest {
    public static Method__c buildMethod(String medium) {
        return new Method__c(
            Method_Number__c = 246,
            Name = 'Assess Business Capabilities',
            Waterfall__c = true,
            Agile__c = false,
            Micro__c = 'Should Use',
            Small__c = 'Won\'t Use',
            Medium__c = medium,
            Large__c = 'Must Use'
        );
    }

    @isTest
    public static void getMethodFields_givenMethodId_shouldReturnMethodInfoFields() {
        Method__c method = buildMethod('Nice to Use');
        insert method;

        Test.startTest();
        Method__c returnedMethod = new MethodDataAccessor()
            .getMethodByMethodId(method.Id);
        Test.stopTest();

        System.assertEquals(method.Method_Number__c, returnedMethod.Method_Number__c, 'should return correct method number');
    }
    
    @isTest
    public static void getMethodFields_givenMethodId_shouldReturnUseFieldsAsEmojiText() {
        Method__c method = buildMethod(' ');
        insert method;

        Test.startTest();
        Method__c returnedMethod = new MethodDataAccessor()
            .getMethodByMethodId(method.Id);
        Test.stopTest();

        System.assertEquals(
            ':wont-use:',
            returnedMethod.Small__c,
            'should return emoji text'
        );
        System.assertEquals(
            '',
            returnedMethod.Medium__c,
            'should return empty string'
        );
    }
}