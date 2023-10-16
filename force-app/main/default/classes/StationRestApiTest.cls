public class StationRestApiTest {

    @AuraEnabled
    public static String runApiTest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Org62APIUser/services/data/v44.0/wave/datasets/VTO_EMP_CENTRAL');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String targetUrl = (String)results.get('currentVersionUrl');
            return targetUrl;
        } else {
            System.debug(res.getBody());
        }
        return '';
    }
    @AuraEnabled
    public static Map<String, Object> performQuery(String datasetId, String employee) {
        //String query = '{query:q = load ' + datasetId + ';q = foreach q generate Activity_Type as Activity_Type,EMP_NAME as EMP_NAME,Employee_Number as Employee_Number,Hours_Volunteered as Hours_Volunteered;q = limit q 100;}';
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('query', 'q = load \"' + datasetId + '\";q = filter q by \'EMP_NAME\' == \"Nicholas McDonald\";q = foreach q generate \'Activity_Type\' as \'Activity_Type\',\'EMP_NAME\' as \'EMP_NAME\',\'Employee_Number\' as \'Employee_Number\',\'Hours_Volunteered\' as \'Hours_Volunteered\';q = limit q 100;');
        gen.writeEndObject();
        String query = gen.getAsString();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Org62APIUser/services/data/v44.0/wave/query');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(query);
        System.debug(req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() == 200) {
            Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> results = (Map<String, Object>) resJson.get('results');
            return results;
            //String targetUrl = (String)results.get('currentVersionUrl');
            //return targetUrl;
        } else {
            System.debug(res.getBody());
        }
        
        return null;
    }
    
    private static String codeStorage() {
        String clientId = '';
        String clientSecret = '';
        String reqbody = 'grant_type=client_credentials&client_id='+clientId+'&client_secret='+clientSecret;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint('https://org62.my.salesforce.com/services/oauth2/authorize');
        HttpResponse res = h.send(req);
        deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
        String atoken = resp1.access_token;
        System.debug('Access Token=========' + atoken);

        Http http1 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setEndpoint('https://abc.dynamics.com/data/Customers');
        req1.setMethod('GET');
        req1.setHeader('Authorization','Bearer '+atoken);
        HttpResponse res1 = http1.send(req1);
        System.debug('Response Body=========' + res1.getBody());
        //return res1.getBody();
        return '';
    }
    
    public class deserializeResponse
    {
        public String token_type;
        public String expires_in;
        public String ext_expires_in;
        public String expires_on;
        public String not_before;
        public String resource;
        public String access_token;
    }
}