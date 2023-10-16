Global class FINSOU_SlackPublisherMockAdmin implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(System.Label.FINS_OU_SLACK_WEBHOOK_ADMIN, req.getEndpoint());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}