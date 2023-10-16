@isTest
global class OrgRefresh_MockUserNamePasswordTest implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake auth response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"test_access_token_username+password_flow","instance_url":"https://test.unamepwd.auth.com"}');
        res.setStatusCode(200);
        return res;
    }
    
}