@IsTest
public with sharing class Metadata_Test {

    testMethod static void testRequest() {

        final String OBJECT_NAME = 'Example';
        final String RECORD_NAME = 'Example';
        final String RECORD_LABEL = 'Example';
        final String FIELD_NAME = 'Example';
        final String VALUE = 'Example';
        
        Test.startTest();
        MetadataRequest request = new MetadataRequest();
        request.init(OBJECT_NAME, RECORD_NAME, RECORD_LABEL);
        request.setObjectName(OBJECT_NAME);
        request.setRecordName(RECORD_NAME);
        request.setRecordLabel(RECORD_LABEL);
        request.addProperty(FIELD_NAME, VALUE);
        request.stage();
        request.execute();
        Test.stopTest();
    }

    testMethod static void testRespose() {
        
        Test.startTest();
        MetadataResponse response = new MetadataResponse();
        response.handleResult(null, null);
        Test.stopTest();
    }
}