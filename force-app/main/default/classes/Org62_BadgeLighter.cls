public with sharing class Org62_BadgeLighter {
/**
 * Class that updates badges in Org62!!!
 *
 */
    public String evaluatorEmail {get; set;} // the evaluator
    public String candidateEmail {get; set;}
    public Decimal score {get; set;} // the score
    public String comments {get; set;} // overall scoring comments
    public String skill {get; set;} // the skill in Services org

    private String accessToken; // access token for integration to org62
    private Id approverUserId;
    private String queryUrl;
    private String badgeName {
        get {
            badgeName = badgeMap.get(skill);
            return badgeName;
        }
        private set;
    }
    private Org62_BadgeLighter_BadgesBean badge62;

    private static Map<String,String> badgeMap;

    private static Org_Refresh_Profile__c refreshProfInstance;

    /* Constructor */
    public Org62_BadgeLighter() {
        system.debug('<==Org62_BadgeLighter==> constructor');
        system.debug(refreshProfInstance);
        OrgRefresh_QueryUtils.setOrgAppName('org62_Badges');
        queryUrl=refreshProfInstance.Endpoint__c + '/services/data/v50.0/query/';
    }

    public Org62_BadgeLighter_BadgesBean getBadge62() {
        login();
        query62Badge();

        // If Badge Not present
        if (badge62 == null) {
            System.Debug('Badge not found in 62 Org.');
            return null;
        }
        else {
            System.Debug('Badge Data: ' + badge62);
            return badge62;
        }
    }

    public void badge() {
        /*  1. Login
            2. Query existing badge data
            3. Update into org62 */

        login();
        query62Badge();

        // Check if badge is present, if not, assign as Acquired
        if (badge62 == null) {
            System.debug('Candidate badge:' + badgeName + ' not present in Org62. Attempting to create');
            Org62_HTSP_Badge__x org62Badge = [select ExternalId, Name__c from Org62_HTSP_Badge__x where Name__c = :badgeName limit 1];
            if (org62Badge == null) {
                System.debug('Could not find Org62 Badge: ' + badgeName );
                throw new Org62_BadgeLighter_Exception('Could not find Org62 Badge: ' + badgeName + '. Please contact your System Administrator.');
            }

            NewUser__x org62User = [select ExternalId, isactive__c, username__c, UserType__c from NewUser__x where UserType__c = 'Standard' and email__c =  :candidateEmail and isActive__c = TRUE];
            if (org62User == null) {
                System.debug('Could not find Org62 User for : ' + candidateEmail);
                throw new Org62_BadgeLighter_Exception('Could not find Org62 User for : ' + candidateEmail + '. Please contact your System Administrator.');
            }
            System.debug('Attempting to assign Badge Id: ' + org62Badge.ExternalId + ' to User Id: ' + org62User.ExternalId);
            assignBadgeAsAcquired((Id) org62User.ExternalId, (Id) org62Badge.ExternalId);
        }
        else if (badge62.State != 'Acquired') {
            update62badge();
        }
    }

    public string assignBadge(Id userId, Id badgeId)
    {
        login();
        string postBody = '{' +
                            '"Badge__c": "' + badgeId + '",' +
                            '"Manager_s_email__c": "stangirala@salesforce.com",' +
                            '"State__c": "Eligible",' +
                            '"User__c": "' + userId + '"' +
                          '}';
        string createResponse = executeCreate(refreshProfInstance.Instance_URL__c, 'HTSP_Badges_Acquired__c', accessToken, postBody);
        System.debug('Create Response: ' + createResponse);
        return createResponse;
    }

    public string assignBadgeAsAcquired(Id userId, Id badgeId)
    {
        login();
        string postBody = '{' +
                            '"Badge__c": "' + badgeId + '",' +
                            '"Manager_s_email__c": "stangirala@salesforce.com",' +
                            '"State__c": "Acquired",' +
                            '"User__c": "' + userId + '"' +
                          '}';
        string createResponse = executeCreate(refreshProfInstance.Instance_URL__c, 'HTSP_Badges_Acquired__c', accessToken, postBody);
        System.debug('Create Response: ' + createResponse);
        return createResponse;
    }

    /* Error inner class */
    public class Org62_BadgeLighter_Exception extends Exception {}

    /* Data bean */
    public class Org62_BadgeLighter_BadgesBean {
        public String Id;
        public String State;
        public String Quiz_Result;
    }

    /* Helper functions */
    private void login() {
        accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN,false);
        System.debug('==Org62_BadgeLighter.login access token== ' + accessToken);
    }

    private void query62Badge() {

        String nextRecordsUrl;
        Boolean isRecordFetchDone;

        badge62 = null;

        if (badgeName == null) throw new Org62_BadgeLighter_Exception('The skill ' + skill + ' cannot be badged. Please contact your System Administrator.');

        String query =
            'select Id, State__c, Quiz_Result__c, LastModifiedDate from HTSP_Badges_Acquired__c ' +
                'where Badge__r.Name = \'' + badgeName + '\' and ' +
                ' User__r.Email = \'' + candidateEmail + '\'';

        System.debug('<== query62Badge ==> query= ' + query);
        String body=OrgRefresh_QueryUtils.executeQuery(queryUrl,accessToken, query);
        System.debug('<== query62Badge ==> body= ' + body);

        body=body.replaceAll('__c','');
        body=body.replaceAll('__r','');

        JSONParser parser = JSON.createParser(body);
        do{
          if(parser.getCurrentName()=='done'){
               isRecordFetchDone=(parser.getText()=='true');
          }
          if(parser.getCurrentName()=='nextRecordsUrl'){
                nextRecordsUrl=parser.getText();
          }
          parser.nextToken();
        } while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));

        parser.nextToken();

        //the following line is wicked cool
        final List<Org62_BadgeLighter_BadgesBean> badgesData = (List<Org62_BadgeLighter_BadgesBean>) parser.readValueAs(List<Org62_BadgeLighter_BadgesBean>.class);
        System.debug('<== query62Badge ==> body= ' + badgesData);

        if (!badgesData.isEmpty())
            badge62 = badgesData[0];

        System.debug('<== query62Badge ==> badge62= ' + badge62);

    }

    public void passQuiz(Id badgeAcquiredId)
    {
        login();
        string postBody = '{' +
                            '"Quiz_Result__c":"Pass"' +
                          '}';
        executeUpdate(refreshProfInstance.Instance_URL__c + '/services/data/v50.0/sobjects/HTSP_Badges_Acquired__c/',
                        accessToken, postBody, badgeAcquiredId);
    }

    public void unLightBadge(Id badgeAcquiredId)
    {
        login();
        string postBody = '{' +
                            '"State__c":"Eligible"' +
                          '}';
        executeUpdate(refreshProfInstance.Instance_URL__c + '/services/data/v50.0/sobjects/HTSP_Badges_Acquired__c/',
                        accessToken, postBody, badgeAcquiredId);
    }

    private void update62Badge() {
        /*  1. Get Approver User Id
            2. Build body
            3. Upsert
        */
        setApproverUserId();
        System.debug('<== update62Badge ==> approverUserId=' + approverUserId);
        if (approverUserId == null)
            throw new Org62_BadgeLighter_Exception('Evaluator is missing in 62 org');

        /* TODO MOVE THIS TO GENERIC CLASSES */
        datetime dt = datetime.now();
        String sNow = dt.formatGmt('YYYY-MM-dd') + 'T' + dt.formatGmt('HH:mm:ss') + 'Z';

        if (comments != null)
            comments = comments.replaceAll('\r\n', '<br/>').replace('"', '\\"');

        /* TODO MOVE */
        String postBody = '{' +
                            '"Manager_Approval__c":"Present - Approved",' +
                            '"SP_Score__c":"' + score.format().replace(',', '.') + '",' +
                            '"SP_Comments__c":"' + comments + '",' +
                            '"SP_Manager__c":"' + approverUserId + '",' +
                            '"Presentation_Result__c":"Pass",' +
                            '"State__c":"Acquired",' +

                            '"Date_of_the_Assessment__c":"' + sNow + '"' +
                            '}';

        executeUpdate(refreshProfInstance.Instance_URL__c + '/services/data/v50.0/sobjects/HTSP_Badges_Acquired__c/',
                        accessToken, postBody, badge62.Id);
    }

    /* TODO MOVE THIS TO UTIL */
    public string executeUpdate(String url,String accessToken, String postBody, Id recordId){
        url += recordId + '?_HttpMethod=PATCH';
        System.debug('===url====' + url);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Authorization', 'OAuth ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeOut(60000);

        System.debug('===Access_Token__c in query====' + accessToken);
        request.setBody(postBody);
        System.debug('===postBody====' + postBody);
        HttpResponse resp = new Http().send(request);

        // throw error
        if (resp.getStatusCode() > 299)
            throw new Org62_BadgeLighter_Exception('Error updating 62 org badge: ' + resp.getStatusCode().format() + resp.getStatus() + '\n' + resp.getBody());

        String respBody = resp.getBody();
        System.debug('===respBody====' + respBody);
        return respBody;
    }

    public string executeCreate(string instanceUrl, string sObjectName, string accessToken, string postBody)
    {
        string fullUrl = instanceUrl + '/services/data/v50.0/sobjects/' + sObjectName + '/';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeOut(60000);

        System.debug('===Access_Token__c in query====' + accessToken);
        request.setBody(postBody);
        System.debug('===postBody====' + postBody);
        HttpResponse resp = new Http().send(request);

        // throw error
        if (resp.getStatusCode() > 299)
        {
            throw new Org62_BadgeLighter_Exception('Error creating ' + sObjectName + ' record in 62 org: ' + resp.getStatusCode().format() + resp.getStatus() + '\n' + resp.getBody());
        }

        String respBody = resp.getBody();
        System.debug('===respBody====' + respBody);
        return respBody;
    }

    private void setApproverUserId() {
        if (evaluatorEmail == null)
            throw new Org62_BadgeLighter_Exception('Evaluator email cannot be null.');

        approverUserId = OrgRefresh_QueryUtils.fetchUserIdbyName(accessToken, evaluatorEmail);
    }

    static {
        refreshProfInstance = Org_Refresh_Profile__c.getInstance('org62_Badges');

        badgeMap = new Map<String,String>();
        List<Bedrock_Badge_Cert_Mapping__mdt> bcml = [select MasterLabel, Org62_Badge_Name__c from Bedrock_Badge_Cert_Mapping__mdt];
        for (Bedrock_Badge_Cert_Mapping__mdt bcm : bcml) {
          badgeMap.put(bcm.MasterLabel, bcm.Org62_Badge_Name__c);
        }

        System.Debug('Domain & Org62 Badge: ' + badgeMap);
    }
}