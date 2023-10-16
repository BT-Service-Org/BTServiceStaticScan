@istest
global class OrgRefresh_MockUpdateTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        //validate the request params through asserts
        System.debug('=====req.getBody()===' + req.getBody());
        System.debug('=====req.getEndpoint()===' + req.getEndpoint());

        // Create a fake auth response
        HttpResponse res = new HttpResponse();
        
        //set the response based on the end point
        //if(req.getEndpoint().endsWith('/result')){ // then this is our status call
            res.setHeader('Content-Type', ' application/json; charset=UTF-8');
            res.setBody('{ "id" : "001T000000NU96UIAT", "errors" : [ ], "success" : true }');
            res.setStatusCode(204);
            res.setStatus('No Content');
            return res;
        //}
    }
}