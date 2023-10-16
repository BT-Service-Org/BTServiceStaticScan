@RestResource(urlMapping='/edhq/postMessage/')
global with sharing class EDHQ_BT_RestSlackMessanger {
    @testVisible
    private static MTH_SlackAppMessengerInterface messenger = new MTH_SlackAppMessenger();

    @HttpPost
    global static String postMessage(){
        String payloadStr = RestContext.request.requestBody.toString(); 
        Id jobId =null;
        MTH_MessagePayload payload = (MTH_MessagePayload)JSON.deserialize(payloadStr, MTH_MessagePayload.class);
        jobId  = messenger.sendGenericMessages(new List<MTH_MessagePayload>{payload});
        return jobId;
    }
}