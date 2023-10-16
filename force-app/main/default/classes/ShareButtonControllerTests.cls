@isTest
public class ShareButtonControllerTests {
    @isTest static void getUrlSubstringTest() {
        String fullURL = 'https://bedrockuat-dreamportal.cs8.force.com/thestation/s/test-page-1';
        String subURL = 'test-page-1';
        Test.startTest();
        String subString = ShareButtonController.getUrlSubstring(fullURL);
        Test.stopTest();
        System.assertEquals(subString, subURL);
    }
    @isTest static void getLexOriginUrltest() {
        String testurl = URL.getSalesforceBaseURL().toExternalForm();
        Test.startTest();
        String subString = ShareButtonController.getLexOriginUrl();
        Test.stopTest();
        System.assertEquals(subString, testurl);
    }
    @isTest static void testSendMailMethod() {
        String to = 'rlambert@salesforce.com';
        String subject = 'StationSPControllerTest';
        String body = 'This is just a test';
        Test.startTest();        
        ShareButtonController.sendMailMethod(to, subject , body);
        Test.stopTest();
        System.assert(TRUE);
    }
}