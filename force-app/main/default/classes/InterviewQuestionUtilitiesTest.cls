@isTest
private class InterviewQuestionUtilitiesTest {

    private static String dummyExistingPosition = 'Dishwasher';
    private static String dummyMissingPosition = 'Punter';
    private static String dummyExistingRecordTypeName = 'Tribunal Interview';
    private static String dummyMissingRecordTypeName = 'Nonexistent Interview';
    private static String defaultCategory = 'Category A';
    private static String positionSpecificCategory = 'Category B';    
    
    @testSetup static void setup() {
        setupInterviewQuestionMap();
    }
    
    private static void setupInterviewQuestionMap() {
                // Setup custom settings for default and specific position to the test record type
        InterviewQuestionCategoryMap__c defaultMapping = new InterviewQuestionCategoryMap__c (
        	Name = InterviewQuestionUtilities.getQuestionCategoryMapKey(
                InterviewQuestionUtilities.DEFAULT_POSITION, dummyExistingRecordTypeName),
            Position__c = InterviewQuestionUtilities.DEFAULT_POSITION,
            Interview_Record_Type_Name__c = dummyExistingRecordTypeName,
            Question_Category__c = defaultCategory
        );
        insert defaultMapping;
        
        InterviewQuestionCategoryMap__c positionSpecificMapping = new InterviewQuestionCategoryMap__c (
        	Name = InterviewQuestionUtilities.getQuestionCategoryMapKey(
                dummyExistingPosition, dummyExistingRecordTypeName),
            Position__c = dummyExistingPosition,
            Interview_Record_Type_Name__c = dummyExistingRecordTypeName,
            Question_Category__c = positionSpecificCategory
        );
        insert positionSpecificMapping;
    }
    
    // if a question category is mapped for a position/recordType, we expect to get that mapping
    static testMethod void validatePositionSpecificQuestionCategory() {
        System.assertEquals(
            InterviewQuestionUtilities.getQuestionCategory(dummyExistingPosition, 
                                                           dummyExistingRecordTypeName),
            positionSpecificCategory);
    }
    
    // if position/rt not mapped, but default/rt mapped we get a default mapping
    static testMethod void validateDefaultPositionQuestionCategory() {
        System.assertEquals(
            InterviewQuestionUtilities.getQuestionCategory(dummyMissingPosition, 
                                                           dummyExistingRecordTypeName),
            defaultCategory);
    }

    // if position/rt not mapped and default/rt not mapped, we get Empty String - ''
    static testMethod void validateUnmappedQuestionCategory() {
         System.assertEquals(
            InterviewQuestionUtilities.getQuestionCategory(dummyMissingPosition, dummyMissingRecordTypeName),
            '');       
    }
}