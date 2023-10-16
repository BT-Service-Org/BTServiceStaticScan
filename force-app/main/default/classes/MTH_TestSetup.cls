@isTest
public with sharing class MTH_TestSetup {
    @TestSetup
    public static void insertCustomSettings(){
        Methodologies_Slack_App_Settings__c settings = new Methodologies_Slack_App_Settings__c(
            Services_Org_URL__c = 'https://sfservices--dighqdev.sandbox',
            General_Information_Slack_Channel_Id__c = 'C044MSYG94Z', 
            Team_Id__c = 'T01PY724468', 
            App_Id__c = 'A043J64NV35', 
            Feedback_Channel_Id__c = 'C0480MX4ZP0',
            Knowledge_Center_URL__c = 'https://sfservices.my.site.com/ServicesCentral/s/methodology'
        );
        insert settings;
    }
}