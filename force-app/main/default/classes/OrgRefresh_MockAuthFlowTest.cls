@isTest
global class OrgRefresh_MockAuthFlowTest implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake auth response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"test_access_token","instance_url":"https://test.auth.com","refresh_token":"test_refresh_token"}');
        res.setStatusCode(200);
        return res;
    }
    
}