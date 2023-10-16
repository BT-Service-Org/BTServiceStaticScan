/**
* @author Narendra Yarlagadda
* @date 11/07/2022
* @description  - ******************************************************
*          FINS OU - Initiative - team-fun-with-fins-engagement
*                 ******************************************************
*         This test class covers the code coverage for FINSOU_SlackPublisher
*/
@isTest
public class FINSOU_SlackPublisher_Test {
    
    //Test Setup Method to insert test user.
    @testSetup static void setup() {
        Profile p1 = [select id,name from profile where name='System Admin - SSO' limit 1];
        User u = new User(Alias = 'why', Email= 'vijay.hari@salesforce.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/New_York', UserName= 'funwithFINS_Test@funwithfins.com');
        insert u;    
    }
    
    //Method to test Video Spot light type to publish into slack.
    @isTest static void testPostToSlack_VideoSpotlight() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('123456789', 'Video Spotlight', 'Why did the Chicken cross the road ?', 
                                       'Because it had to write a apex test class', 0.5, true, '', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Enablement type to publish into slack.
    @isTest static void testPostToSlack_Enablement() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('123456789', 'Enablement', 'AMER Del Eng Res Guide', 
                                       'This guide is meant to provide an extensive list of resources',
                                       0.75, true, 'WWW.Google.com', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Humor type to publish into slack.
    @isTest static void testPostToSlack_Humor() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('$$uniquename$$123', 'Humor', 'Youtube guide getting better view', 
                                       'This guide is meant to provide an extensive list of resources '+
                                       'for Youtube guide getting better view', 3, true, 'WWW.yoututbe.com', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test FunFact type to publish into slack.
    @isTest static void testPostToSlack_FunFact() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('ok $$5343', 'Fun Fact', 'Fun fact subject', 
                                       'Fun fact message', 4, true, 'WWW.yahoo.com', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Announcement type to publish into slack.
    @isTest static void testPostToSlack_Announcement() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('$$announcement uniquename$$123', 'Announcement', 'announcement sub', 
                                       'announcement mes', 5, true, '', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Consulting Wisdom type to publish into slack.
    @isTest static void testPostToSlack_ConsultingWisdom() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('$$consulting wisdom$$123', 'Consulting Wisdom', 'Consulting Wisdom sub', 
                                       'Consulting Wisdom mes', 6, true, 'WWW.yoututbe.com', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Inspiration type to publish into slack.
    @isTest static void testPostToSlack_Inspiration() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Tuesday');
        flowInputString.add('Odd');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('okkkk', 'Inspiration & Motivation', 'Inspiration & Motivation subject', 
                                       'Inspiration & Motivation message', 7, true, 'WWW.yahoo.com', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Culture type to publish into slack.
    @isTest static void testPostToSlack_Culture() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Friday');
        flowInputString.add('Even');
        flowInputString.add('25');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('$$culture$$', 'Culture', 'Culture subject', 
                                       'Culture message', 8, true, '', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to test Affirmation type to publish into slack.
    @isTest static void testPostToSlack_Affirmation() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Monday');
        flowInputString.add('Even');
        flowInputString.add('26');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        //Initilize FINSOU_Engagement Record
        FINSOU_Engagement__c funRecord = initiate_FINSOU_Engagement('$$culture$$', 'Affirmation', 'Affirmation subject', 
                                       'Affirmation message', 9, true, '', u);
        insert funRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        FINSOU_Engagement__c tstFunRecord  = [Select name,Sent_On__c from FINSOU_Engagement__c where id =: funRecord.Id];
        system.assertEquals(System.today(), tstFunRecord.Sent_On__c);
        Test.stopTest();
    }
    
    //Method to cover wrapper class.
    @isTest static void testPostToSlack_Wrapper() {
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            
            request.setEndpoint('callout:FINSOU_SLACK_BOT_NC'+'?email=vijay.hari@salesforce.com');
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+ '{!$Credential.Password}');
            
            response = http.send(request);
            String responseBody = response.getBody();
            
            FINSOU_SlackAPI_UserInfo userInfo = (FINSOU_SlackAPI_UserInfo)JSON.deserialize(responseBody, FINSOU_SlackAPI_UserInfo.class);
            system.debug('@@@@@@@1 userInfo '+userInfo);
            system.debug('@@@@@@@2 userReal_Name '+userInfo.User.real_name);
        Test.stopTest(); 
    }
    
    //Method to test exception scenario.
    @isTest static void testPostToSlack_Exception() {
        
        user u = [select id from user where email =: 'vijay.hari@salesforce.com' limit 1];        
        //build flow inputString
        List<String> flowInputString = new List<String>();
        flowInputString.add('Monday');
        flowInputString.add('Even');
        flowInputString.add('26');
        
        //build flowinput class
        FINSOU_SlackPublisher.flowInputs finsSP_FI = new FINSOU_SlackPublisher.flowInputs();
        finsSP_FI.strInputs = flowInputString;
        
        //build flowinput List
        List<FINSOU_SlackPublisher.flowInputs> finsSP_FI_List = new List<FINSOU_SlackPublisher.flowInputs>();
        finsSP_FI_List.add(finsSP_FI);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FINSOU_SlackPublisherMock());
        FINSOU_SlackPublisher.postToSlack(finsSP_FI_List);
        Test.stopTest();
        
        //bad test
        FINSOU_Slack_User fs = new FINSOU_Slack_User();
		fs.id = '1234';
        fs.real_name = 'bad';
    }
    
    //Method to initilize test data for FINSOU_Engagement.
    public static FINSOU_Engagement__c initiate_FINSOU_Engagement(String name, String type, String subject, String message, Decimal priority,
                                                                  Boolean approvedToSent, String link, user u){
                                                                      
                                                                      FINSOU_Engagement__c funRecord = new FINSOU_Engagement__c();
                                                                      
                                                                      funRecord.Name = name;
                                                                      funRecord.Type__c = type;
                                                                      funRecord.Subject__c = subject;
                                                                      funRecord.Message__c = message;
                                                                      funRecord.Priority__c = priority;
                                                                      funRecord.Approved_to_Send__c = approvedToSent;
                                                                      funRecord.Links__c = link;
                                                                      funRecord.Submitted_By__c = u.Id;
                                                                      
                                                                      return funRecord;
                                                                      
                                                                  }
    
}