/**
* @author Vijay Hari
* @date 05/16/2022
* @description  - ******************************************************
*          FINS OU - Initiative - team-fun-with-fins-engagement
*                 ******************************************************
*          This class posts a slack message and is invoked from
*          a flow which is scheduled to run on based on triggering criteria
*
*          v2. 06/23/2022
*		   1. Different emojis for different types
*          2. Do not display links if there are no links
*          3. Triggering criteria for various types
*		   4. Bypass schedule
*
*          v4. 10/29/2022
*		   1. @mentions for submitter email
*          2. named credentials to hide bot token
*          3. Monday Morning Afformations i.e. revised schedule (post deployment manual step in Schedule-o-matic9000)
*          
*          v5
*          Removed IsTestRunning to cover the API response methods.
*          
*          v6
*          1. new line characters are substitured for <br> <p>, bold also works (only for message)
*		   2. posts to multiple channel is now possible - second webhook i.e. ALL OU channel
*
*/

public with sharing class FINSOU_SlackPublisher {
    
    public class flowInputs {
        @InvocableVariable
        public List<String> strInputs;
    }
     
    private static final String SLACK_URL = System.Label.FINS_OU_SLACK_WEBHOOK;
    private static final String SLACK_URL_ALL_OU = System.Label.FINS_OU_SLACK_WEBHOOK_ALL_OU;
    private static final String SLACK_URL_ADMIN = System.Label.FINS_OU_SLACK_WEBHOOK_ADMIN;
    private static final String FINSOU_BYPASS_SCHEDULE = System.Label.FINSOU_BYPASS_SCHEDULE;
    private static final String CONSTANT_MONDAY = 'Monday';
    private static final String CONSTANT_FRIDAY = 'Friday';
    
    //3-28-2023
    //multichannel post test
    //https://hooks.slack.com/services/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 
    
    
    
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack (List<flowInputs> triggeringCriteria) {

        List<String> criteriaList =  triggeringCriteria[0].strInputs;
        //System.debug('---criteriaList[0]='+criteriaList[0]);
        //ONLY execute if it's a monday or friday
        if( (CONSTANT_FRIDAY.equals(criteriaList[0]) || CONSTANT_MONDAY.equals(criteriaList[0])) &&
            'false'.equalsIgnoreCase(FINSOU_BYPASS_SCHEDULE) ){
            callPostToSlack( triggeringCriteria );
        }else if('true'.equalsIgnoreCase(FINSOU_BYPASS_SCHEDULE)) {
            callPostToSlack( triggeringCriteria );
        }
    }
    public static void callPostToSlack(List<flowInputs> triggeringCriteria){
        
        try{
            //we have to deconstruct the triggeringCriteria
            String soql_messageType = messageTypeSOQL(triggeringCriteria);
            String soql_base = 'Select Id,Message__c,Submitted_By__r.Name,'+
                ' Priority__c,Sent_On__c,Subject__c,Type__c,Links__c, '+
                ' Submitted_by__r.email '+
                ' from FINSOU_Engagement__c  '+
                ' where Sent_On__c = null ' +
                ' and Approved_to_Send__c = true ';
            String soql_orderby = ' order by Priority__c limit 1 ';
            String dynamicSOQL ='';
            if('true'.equalsIgnoreCase(FINSOU_BYPASS_SCHEDULE)){
                dynamicSOQL = soql_base + soql_orderby;
            }else {
                dynamicSOQL = soql_base + soql_messageType + soql_orderby;    
            }
            
            FINSOU_Engagement__c funRecord = Database.query(dynamicSOQL);
            
            String strMessage;
            if( funRecord != null ){
                
                //3-28-2023
                String msgHTMLStripped = formatMessage (funRecord.Message__c);

				String msgLinkStripped = funRecord.Links__c;
                
                if(funRecord.Links__c != null){
                    msgLinkStripped = msgLinkStripped.stripHtmlTags();
                }else{
                    msgLinkStripped = '';
                }
                //construct main heading
                strMessage = ':fun-with-fins: *Fun with FINS - FUN Fact!!* :fun-with-fins:\n';
                //construct emoji/topic based on type
                strMessage += constructedEmojiString(funRecord.Type__c);
                
                strMessage += '\n';
                strMessage += '*Subject :* '+funRecord.Subject__c  +'\n';
                strMessage += '*Message :* '+msgHTMLStripped +'\n';
                
                //if there no links, the links section will not display
                if(msgLinkStripped.length() > 0 ){
                    strMessage += '*Links :* \n'+msgLinkStripped +'\n';    
                }

                strMessage += '*Submitted by :* <@'+ getSlackUserId(funRecord.Submitted_by__r.email)  +'> \n';

                Map<String,Object> msg = new Map<String,Object>();
                msg.put('text',strMessage) ;
                msg.put('mrkdwn', true);
                msg.put('unfurl_media',true);
                msg.put('unfurl_links',true);
                
                String body = JSON.serialize(msg);   
                System.debug('---body='+body);
                
                System.enqueueJob(new QueueableSlackPost(SLACK_URL, 'POST', body));
                               
                //update the message sent so message does not get picked up again
                funRecord.Sent_On__c = System.today();
                update funRecord;
            }              
        }catch(Exception e){
            String strMessage;
            strMessage = ':confused::confused: *Something went wrong while delivering the biweekly Fun Facts Slack Message. :thinking_face::thinking_face: \n'+
                'Please check the following:\n'+
                '1)FunWithFins Records \n'+
                '2)Any exceptions in endpoints \n'+
                '3)Check debug logs \n';
            Map<String,Object> msg = new Map<String,Object>();
            msg.put('text',strMessage) ;
            msg.put('mrkdwn', true);
            String body = JSON.serialize(msg); 
            System.enqueueJob(new QueueableSlackPost(SLACK_URL_ADMIN, 'POST', body));
        }
    }
    public class QueueableSlackPost implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackPost(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            //3-28-2023 - ALL OU channel post 
            if ( 'true'.equalsIgnoreCase(System.Label.FINS_OU_SLACK_POST_TO_ALL_OU) ){
				HttpRequest req2 = new HttpRequest();
                req2.setEndpoint( SLACK_URL_ALL_OU );
                req2.setMethod(method);
                req2.setBody(body);
                Http http2 = new Http();
                HttpResponse res2 = http2.send(req2);                
            }

        }
    }
    /**
    * @author Vijay Hari
    * @date 06/23/2022
    * @description  
    *          This method deconstructs the flow inputs and determines
    *		   what type of message to be delivered. Subsequently, returns
    * 		   appropriate SOQL String
    */
    private static String messageTypeSOQL(List<flowInputs> triggeringCriteria){
        //we have to deconstruct the triggeringCriteria
        //1. flowInputs[0] is the Day of the week
        //2. flowInputs[1] is odd or even
        //3. flowInputs[2] is the actual number of the week
        List<String> criteriaList =  triggeringCriteria[0].strInputs;
        //System.debug('---criteriaList[0]='+criteriaList[0]);
        //System.debug('---criteriaList[1]='+criteriaList[1]);
        //System.debug('---criteriaList[2]='+criteriaList[2]);
        if ( criteriaList[0] == 'Friday' ){
            if ( criteriaList[1] == 'Odd' ){
				return ' and Type__c = \'Video Spotlight\'';
            }else{
                return ' and Type__c not in (\'Video Spotlight\',\'Affirmation\')';
            }
        }else if (criteriaList[0] == 'Monday' ){
            return ' and Type__c = \'Affirmation\'';
        }
        return null;
    }
    /**
    * @author Vijay Hari
    * @date 06/23/2022
    * @description  
    *          This method constructs the emojis based on the type of message
    */
    private static String constructedEmojiString(String type){
        String strMessage = '';
        if ( type == 'Humor'){
            strMessage += ':rolling_on_the_floor_laughing::laughter:';
            strMessage += 'Today\'s topic is a joke' ;
            strMessage += ':laughter::rolling_on_the_floor_laughing:';
        }
        else if ( type == 'Enablement'){
            strMessage += ':blue_book::orange_book:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':blue_book::orange_book:';
        }else if ( type == 'Affirmation'){
            strMessage += ':bold-sparkles::post-it:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':post-it::bold-sparkles:';
        }else if ( type == 'Video Spotlight'){
            strMessage += ':film_projector:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':film_projector:';
        }else if ( type == 'Inspiration & Motivation'){
            strMessage += ':gc-motivate-champion::keepgoingggg:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':keepgoingggg::gc-motivate-champion:';
        }else if ( type == 'Culture'){
            strMessage += ':earth_spin:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':earth_spin:';
        }else if ( type == 'Announcement'){
            strMessage += ':megaphone3::megaphone3:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':megaphone3::megaphone3:';
        }else if ( type == 'Consulting Wisdom'){
            strMessage += ':csg-professional-services::owl_book:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':owl_book::csg-professional-services:';
        }else if ( type == 'Fun Fact'){
            strMessage += ':factstrue::knowledge:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':knowledge::factstrue:';
        }else if ( type == 'Productivity'){
            strMessage += ':increase::increase:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':increase::increase:';
        }else if ( type == 'Life at Salesforce'){
            strMessage += ':life::salesforce:';
            strMessage += 'Today\'s topic is ' +type ;
            strMessage += ':salesforce::life:';
        }
        return strMessage;
    }
    /**
    * @author Vijay Hari
    * @date 07/08/2022
    * @description  
    *          This method returns the slack user id based on a given email.
    */
    private static String getSlackUserId(String p_submitterEmail){
        
			Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            
            //request.setEndpoint('https://slack.com/api/users.lookupByEmail?email='+p_submitterEmail);
            request.setEndpoint('callout:FINSOU_SLACK_BOT_NC'+'?email='+p_submitterEmail);
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+ '{!$Credential.Password}');
            
            response = http.send(request);
            String responseBody = response.getBody();
            system.debug('@@@@@@@1 userInfo ');
            FINSOU_SlackAPI_UserInfo userInfo = (FINSOU_SlackAPI_UserInfo)JSON.deserialize(responseBody, FINSOU_SlackAPI_UserInfo.class);
            system.debug('@@@@@@@2 userInfo '+userInfo);
            if(userInfo!=null){
                return userInfo.user.id;
            }   
        
        return null;
    }
    
    /**
    * @author Vijay Hari
    * @date 03/28/2023
    * @description  
    *          This method formats for new line chars and bold ONLY.
    */
    private static String formatMessage(String p_inputString){
	
        String backlash = '\n';
        String backlashReplacement = '---n';
        String strongBegin = '<strong>';
        String strongEnd = '</strong>';
        String linebreak = '<br>';
        String paragraphEnd = '</p>';
        
        String msgHTML_UnStripped = p_inputString;
        String msgHTMLStripped ='';
        msgHTML_UnStripped = msgHTML_UnStripped.replaceAll(backlash, backlashReplacement);
        msgHTML_UnStripped = msgHTML_UnStripped.replaceAll(linebreak, backlashReplacement);
        msgHTML_UnStripped = msgHTML_UnStripped.replaceAll(paragraphEnd, backlashReplacement);
        msgHTML_UnStripped = msgHTML_UnStripped.replaceAll(strongBegin, '*');
        msgHTML_UnStripped = msgHTML_UnStripped.replaceAll(strongEnd, '*');
        
        //System.debug( msgHTML_UnStripped );
        
        msgHTMLStripped = msgHTML_UnStripped.stripHtmlTags();
        
        //replace the /n after stripping
        msgHTMLStripped = msgHTMLStripped.replaceAll(backlashReplacement, backlash);
        
        return msgHTMLStripped;
    }
}