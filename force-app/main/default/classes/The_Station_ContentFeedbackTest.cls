@isTest
public class The_Station_ContentFeedbackTest {
    @isTest static void testFeedbackController() {

        Id successProgramRecordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id contentVersionRecordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        String content1Name = 'TEST Success Program';
        String content1Onwer = 'Rod Kalpakoff';
        String content1URL = 'https://org62.lightning.force.com/lightning/r/Success_Program__c/aCe3000000000GGCAY/view';
        String content2Name = 'TEST Content Version';
        String content2Onwer = 'Kevin Boyer';
        String content2URL = 'https://org62.lightning.force.com/lightning/r/ContentDocument/0690M000007FJ4nQAG/view';
        String localUser1 = null;
        String localUser2 = null;        
        User usr = null;
        String accountName = 'Salesforce.com - DO NOT TOUCH';
        String expectedValue = null;

        Test.startTest();

        User u = [SELECT Id FROM User WHERE name = 'David Mierke' AND alias = 'DMier' LIMIT 1];
        if (u == null) {
            System.debug('*** MAJOR ISSUE - COULD NOT EVEN FIND DAVID MIERKE');
        } else {
            expectedValue = u.Id;
        }


        Account a = new Account(Name = accountName);
        insert a;
        System.debug('*** testFeedbackController accountId : '+a.Id);

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
        System.debug('*** testFeedbackController User Name : '+n);

        Profile p = [select id from Profile where name = 'Standard User'];
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
        
        System.runAs(usr) {            
            Station_Content__c SPContent = new Station_Content__c(Name=content1Name,
                                                                RecordTypeId=successProgramRecordTypeId,
                                                                Content_Type__c='Success Program',
                                                                Content_URL__c=content1URL,
                                                                Order__c=1);
            insert SPContent;
            Station_Content__c CVContent = new Station_Content__c(Name=content2Name,
                                                                RecordTypeId=contentVersionRecordTypeId,
                                                                Content_Type__c='Content Version',
                                                                Content_URL__c=content2URL,
                                                                Order__c=2);
            insert CVContent;

            localUser1 = The_Station_ContentFeedbackController.getFeedbackCaseLocalOwnerId(SPContent.Id);

            System.debug('*** testGetContentRecords SPContent.OwnerId : ' + SPContent.OwnerId);   
            System.debug('*** testGetContentRecords localUser1        : ' + localUser1);               

            localUser2 = The_Station_ContentFeedbackController.getFeedbackCaseLocalOwnerId(CVContent.Id);

            System.debug('*** testGetContentRecords CVContent.OwnerId : ' + CVContent.OwnerId);        
            System.debug('*** testGetContentRecords localUser2        : ' + localUser2);                              
        }
        Test.stopTest();
        System.debug('*** testGetContentRecords localUser1 : ' + localUser1);   
        System.debug('*** testGetContentRecords localUser2 : ' + localUser2);   
        System.assertEquals(expectedValue, localUser1);
        System.assertEquals(expectedValue, localUser2);
    }
}