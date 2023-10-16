@IsTest
public with sharing class EDHQ_BT_RestSlackMessangerTest {
    @IsTest 
    static void testPostMessage() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/edhq/postMessage/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"notify": "test@salesforce.com"}');
        RestContext.request = request;
        // Update status of existing record to Working
        EDHQ_BT_RestSlackMessanger.messenger = new MTH_SlackAppMessengerMock();
        ID jobId = EDHQ_BT_RestSlackMessanger.postMessage();
        // Verify record was updated
        Assert.areNotEqual(null, jobId);
        Assert.areEqual(1, ((MTH_SlackAppMessengerMock)EDHQ_BT_RestSlackMessanger.messenger).callsToGenericMsg);
    }  

}