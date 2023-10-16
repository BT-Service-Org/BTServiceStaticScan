public with sharing class Org62_BadgePoster {
/**
 * Class that posts badge attainment to Chatter Groups in Org62!!!
 * 
 */
    /* Data bean */
    public class Org62_BadgePoster_BadgesBean {
        public String Id;
        public String email;
        public String Name;
    }   
 
    public String[] mentionEmails {get; set;} // the evaluator
    public String candidateEmail {get; set;}
    public String comments {get; set;} //  comments
    public String groupId {get;set;} // Group Id from Org62 to post this feed. Can this be dynamically retrieved?
 
    private String accessToken; // access token for integration to org62 
    private String queryUrl;
    
    private Map<String, Org62_BadgePoster_BadgesBean> emailToIdMap;
    
    
    private static Org_Refresh_Profile__c refreshProfInstance;
 
    /* Constructor */
    public Org62_BadgePoster() {  
        system.debug('<==Org62_BadgePoster==> constructor');
        OrgRefresh_QueryUtils.setOrgAppName('org62_Badges');
    }
    
    public void badge(String candidateEmail, String mentorEmail,String judgeEmail, String skill) {
        /*  1. Login
            2. Query existing badge data
            3. Update into org62 */
        login();

        PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('BadgeChatterComments'); 
        if (paTemplate!=null)
           this.comments = paTemplate.Value__c;
        paTemplate = PA_Onboarding_Property__c.getValues('BadgeChatterMentions');
        if (paTemplate!=null) {
            String mentionList = paTemplate.Value__c;
            System.debug('mention list '+mentionList);
            mentionEmails = mentionList.split(',',-1);
            System.debug('mention emails '+mentionEmails);  
            
            //Add the Mentor and Judge emails so that they get @mentioned
            if (mentorEmail != null)
                mentionEmails.add(mentorEmail);
            mentionEmails.add(judgeEmail);
        }
        paTemplate = PA_Onboarding_Property__c.getValues('BadgeChatterGroupId'); 
        if (paTemplate!=null)
           this.groupId = paTemplate.Value__c;
    
        query62Emails(candidateEmail);

        post62Badge(candidateEmail, skill); 
    }
 
    /* Error inner class */
    public class Org62_BadgePoster_Exception extends Exception {}
 
 
    /* Helper functions */
    private void login() {
        accessToken=OrgRefresh_AuthUtils.authenticateUser(OrgRefresh_AuthFlows.OAUTH_REFRESHTOKEN,false);
        System.debug('==Org62_BadgeLighter.login access token== ' + accessToken);   
    }
    
    private String constructEmailList(String candidateEmail) {
        String emailList = '\''+candidateEmail+'\'';
        for (String email:mentionEmails) 
            if (emailList.indexOf(email) < 0)
                emailList = emailList + ',\'' + email + '\'';
        return emailList;
    }
    
    private void query62Emails(String candidateEmail) {

        String nextRecordsUrl;
        Boolean isRecordFetchDone;

        emailToIdMap = new Map<String, Org62_BadgePoster_BadgesBean>();
        
        String query = 
            'select Id, Email, Name from User ' +
                'where UserType=\'Standard\' and isActive=true and Email in (' + constructEmailList(candidateEmail) + ')';

        System.debug('<== query62Badge ==> query= ' + query);
        OrgRefresh_QueryUtils.setOrgAppName('org62_Badges');

        queryUrl=refreshProfInstance.Instance_URL__c + '/services/data/v29.0/query/';       
        String body=OrgRefresh_QueryUtils.executeQuery(queryUrl,accessToken, query);
        System.debug('<== query62Badge ==> body= ' + body);
 
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
        final List<Org62_BadgePoster_BadgesBean> badgesData = (List<Org62_BadgePoster_BadgesBean>) parser.readValueAs(List<Org62_BadgePoster_BadgesBean>.class);
        System.debug('<== query62Badge ==> body= ' + badgesData);

        if (!badgesData.isEmpty())
            for (Org62_BadgePoster_BadgesBean bean : badgesData)
                emailtoIdMap.put(bean.email, bean);
        

        System.debug('<== query62Badge ==> emailId map= ' + emailtoIdMap);
        
    }
    
    private void post62Badge(String candidateEmail, String skill) {
        datetime dt = datetime.now();
        String sNow = dt.formatGmt('YYYY-MM-dd') + 'T' + dt.formatGmt('HH:mm:ss') + 'Z';        
        Org62_BadgePoster_BadgesBean candidate = emailToIdMap.get(candidateEmail);
        String postBody = '{ "body": { ' +
      '"messageSegments" : [ ';
      
        if (comments != null) {
                    comments = comments.replaceAll('<skill>', skill);
                    Integer candidateIdx = comments.indexOf('<candidate>');
                    if (candidateIdx!=-1) {
                        String preCandidateStr = comments.substring(0, candidateIdx);
                        String postCandidateStr = comments.substring(candidateIdx + 11);
                        
                        postBody = postBody + '{"type":"Text", "text": "' + preCandidateStr +'"},' +
                                              '{"type":"mention", "id":"' + candidate.id+'"},' +
                                              '{"type":"Text", "text":"'+ postCandidateStr + '"}\r\n';
                    } else {
                        postBody = postBody + '{"type":"Text", "text": "' + comments +'"}\r\n';                     
                    }           
        } else {
                postBody = postBody + '{"type":"Text", "text": "Congratulations "},' +
                                      '{"type":"mention", "id":"' + candidate.id+'"},' +
                                      '{"type":"Text", "text":" on obtaining your '+ skill + ' Badge."}\r\n';
        }
        
        for (Org62_BadgePoster_BadgesBean bean:emailToIdMap.values()) {
            if (bean.email!=candidateEmail)
                postBody = postBody + ', {"type":"mention","id":"'+bean.id+'"}';
        }
        
        postBody = postBody + ']}}';
        
        System.debug('post body '+postBody);
        
        postFeed(refreshProfInstance.Instance_URL__c + '/services/data/v30.0/chatter/feeds/record/', 
                        accessToken, postBody, groupId);
    }   

    public string postFeed(String url,String accessToken, String postBody, String recordId){
        url += recordId + '/feed-items?_HttpMethod=POST';
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
            throw new Org62_BadgePoster_Exception('Error posting feed : ' + resp.getStatusCode().format() + resp.getStatus() + '\n' + resp.getBody());
        
        String respBody = resp.getBody();
        System.debug('===respBody====' + respBody);
        return respBody;
    }
    static {
        refreshProfInstance = Org_Refresh_Profile__c.getInstance('org62_Badges');
    }    
}