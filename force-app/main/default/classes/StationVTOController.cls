public class StationVTOController {
	@AuraEnabled
    public static String getCurrentVersion() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Org62APIUser/services/data/v44.0/wave/datasets/VTO_EMP_CENTRAL');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('GetCurrentVersion:' +res.getStatusCode());
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
    public static Map<String, Object> performQuery(String datasetId) {
        //String query = '{query:q = load ' + datasetId + ';q = foreach q generate Activity_Type as Activity_Type,EMP_NAME as EMP_NAME,Employee_Number as Employee_Number,Hours_Volunteered as Hours_Volunteered;q = limit q 100;}';
        
        String runningUserEmail = UserInfo.getUserEmail();
        Org62_User__x org62User = [SELECT ExternalId, Email__c, Name__c FROM Org62_User__x WHERE Email__c = :runningUserEmail LIMIT 1];
        //System.debug('Org62 username: ' + org62User.Name__c);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('query', 'q = load \"' + datasetId + '\";q = filter q by \'EMP_NAME\' == \"' + org62User.Name__c + '\";q = filter q by date(\'Shift_Start_Date_Time_Year\', \'Shift_Start_Date_Time_Month\', \'Shift_Start_Date_Time_Day\') in ["current fiscal_year".."current fiscal_year"];q = foreach q generate \'Activity_Type\' as \'Activity_Type\',\'EMP_NAME\' as \'EMP_NAME\',\'Employee_Number\' as \'Employee_Number\',\'Hours_Volunteered\' as \'Hours_Volunteered\',\'Shift_Start_Date_Time_sec_epoch\' as \'Shift_Start_Date_Time_sec_epoch\';q = order q by \'Shift_Start_Date_Time_sec_epoch\' desc;q = limit q 100;');
        //q = filter q by date(\'Shift_Start_Date_Time_Year\', \'Shift_Start_Date_Time_Month\', \'Shift_Start_Date_Time_Day\') in [\"current fiscal_year\"..\"current_fiscal_year\"]
        gen.writeEndObject();
        String query = gen.getAsString();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Org62APIUser/services/data/v44.0/wave/query');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(query);
        //System.debug(req.getBody());
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
}