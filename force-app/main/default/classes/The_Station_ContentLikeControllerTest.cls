@isTest
public with sharing class The_Station_ContentLikeControllerTest {
    public static String CSG_BASE_PROFILE = 'CSG Base Profile';
    public The_Station_ContentLikeControllerTest() {

    }
    public static Station_Content__c createContent() {    
        Id recordTypeIdContent = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('URL').getRecordTypeId();
        Station_Content__c content = new Station_Content__c(Name='Test Content',
                                                            RecordTypeId = recordTypeIdContent,
                                                            Content_Type__c = 'URL',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);

        insert content;        
        return content;
    }

    public static User createTestUser() {                

        String accountName = 'Salesforce.com - DO NOT TOUCH';
        String expectedValue = null;
        User usr = null;
        Account a = new Account(Name = accountName);
        insert a;

        List<String> firstNames = new List<String>{'Ally','Brandy','Casey','Debbie','Elisa'};
        Integer listSize1 = firstNames.size() - 1;
        Integer randomNumber1 = Integer.valueof((Math.random() * listSize1));
        String fName = firstNames[randomNumber1];
        List<String> lastNames = new List<String>{'Awesome','Bodacious','Cool','Dominant','Excellent'};
        Integer listSize2 = lastNames.size() - 1;
        Integer randomNumber2 = Integer.valueof((Math.random() * listSize2));
        String lName = lastNames[randomNumber2];
        Integer randomNumber3 = Integer.valueof((Math.random() * 100));
        String uName = fName+'.'+lName+'.'+randomNumber3+'@testorg.com';
        String n = fName + ' ' + lName;

        Profile p = [select id from Profile where name =: CSG_BASE_PROFILE];
        usr = new User();
        usr.Alias = 'TUser';
        usr.Email = 'newuser@testorg.com';
        usr.EmailEncodingKey = 'UTF-8';
        usr.FirstName = fName;
        usr.LastName = lName;
        usr.Username = uName;
        usr.ProfileId = p.Id;
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';        
        usr.TimeZoneSidKey = 'America/Los_Angeles';

        insert usr;
        
        return usr;
    }

    public static Station_Like_Action__c createStationLikeAction(Station_Content__c con, User Usr) {
        Station_Like_Action__c likeAction = new Station_Like_Action__c(
            Station_Content__c = con.id,
            User__c = Usr.id
        );
        insert likeAction;
        return likeAction;
    }

    @isTest static void test_isContentLikedByRunningUser(){
        Station_Content__c c = createContent();
        User usr = createTestUser();
        Station_Like_Action__c l = createStationLikeAction(c, usr);
        System.runAs(usr) {
            boolean isLike = The_Station_ContentLikeController.isContentLikedByRunningUser(c.id);
            System.assertEquals(isLike, false);
            integer likecount = The_Station_ContentLikeController.getLikeCount(c.id);
            System.assertEquals(likecount,0);
        }
    }
    @isTest static void test_LikeContent(){
        Station_Content__c c = createContent();
        User usr = createTestUser();
        System.runAs(usr) {
            boolean isLike = The_Station_ContentLikeController.LikeContent(c.id);
            System.assertEquals(isLike, false);
            isLike = The_Station_ContentLikeController.LikeContent(c.id);
            System.assertEquals(isLike,false);
        }
    }

    
}