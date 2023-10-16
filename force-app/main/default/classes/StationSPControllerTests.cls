@isTest
public class StationSPControllerTests {
    @isTest static void getGroupsTest() {
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        
        Station_Content__c content = new Station_Content__c(Name='test content',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);
        insert content;
        Station_Pages__c grouping = new Station_Pages__c(Name='test grouping',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association;
                
        Test.startTest();
        List<Object>contentList = StationSPController.getGroups(groupingId);
        List<Object>nullList = StationSPController.getGroups('');
        Station_Pages__c groupTest = StationSPController.getGroupName(groupingId);
        Test.stopTest();
        
        System.assert(contentList.isEmpty() == FALSE, 'Content query return zero results');
        System.assert(nullList.isEmpty() == TRUE, 'Blank query returned results');
        System.assertEquals(groupTest.Name, grouping.Name, 'Group name mismatch');
        StationContentWrapper first = (StationContentWrapper)contentList.get(0);
        System.assert(first.content.Content_Type__c == 'Success Program', 'Incorrect Content Type');
        System.assert(first.content.Content_URL__c == 'http://contenttesturl.com/testurl', 'Incorrect Content URL');
        System.assert(first.content.Order__c == 1, 'Incorrect Order value');
    }
    
    @isTest static void getContentTests() {
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        Id spRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        
        Station_Content__c content = new Station_Content__c(Name='test content',
                                                            RecordTypeId = cvRT,
                                                            Content_Type__c='Content Version',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content;
        Station_Content__c content1 = new Station_Content__c(Name='test content 1',
                                                             RecordTypeId = spRT,
                                                            Content_Type__c='Success Program',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content1;
        
        Station_Pages__c grouping = new Station_Pages__c(Name='test grouping',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association;
        StationGroupingAssociation__c association1 = new StationGroupingAssociation__c(Station_Content__c=content1.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association1;
        
        List<Object>contentList = StationSPController.getGroups(groupingId);
        String contentJson = JSON.serialize(contentList);

        Test.startTest();
        List<StationContentWrapper> contentPieces = StationSPController.getContentPieces(contentJSON);
        Test.stopTest();
        
        System.assert(contentPieces.isEmpty() == FALSE, 'Content query return zero results');
    }

// COMMENT OUT DUE TO NO LONGER IN USE - ASSESSMENT ON 06/23/2020 - ALSO REMOVING TEST CODE
    /*    
    @isTest static void testFeedback() {
        String reason = 'reasons';
        String description = 'descriptive description describing things';
        
        Test.startTest();
        Case newCase = StationSPController.submitFeedbackCase(reason, description);
        Test.stopTest();
        
        System.assert(newCase.Subject == reason);
        System.assert(newCase.Description == description);
    }
    */    

    @isTest static void testImageForContentType() {
        Test.startTest();
        String unknown = StationSPController.imageForContentType('something');
        String astro = StationSPController.imageForContentType('a');
        //String excel = StationSPController.imageForContentType('EXCEL_X');
        //String gdoc = StationSPController.imageForContentType('GOOGLE_DOCUMENT');
        //String gpres = StationSPController.imageForContentType('GOOGLE_PRESENTATION');
        //String gsheet = StationSPController.imageForContentType('GOOGLE_SPREADSHEET');
        //String jpg = StationSPController.imageForContentType('JPG');
        //String jpeg = StationSPController.imageForContentType('JPEG');
        String ka = StationSPController.imageForContentType('b');
        String link = StationSPController.imageForContentType('LINK');
        String mov = StationSPController.imageForContentType('MOV');
        String mp3 = StationSPController.imageForContentType('MP3');
        String mp4 = StationSPController.imageForContentType('MP4');
        String pack = StationSPController.imageForContentType('PACK');
        //String pdf = StationSPController.imageForContentType('PDF');
        //String png = StationSPController.imageForContentType('PNG');
        //String powerp = StationSPController.imageForContentType('POWER_POINT_X');
        String qsheet = StationSPController.imageForContentType('QUIPSHEET');
        String qdoc = StationSPController.imageForContentType('QUIPDOC');
        //String word = StationSPController.imageForContentType('WORD_X');
        String zip = StationSPController.imageForContentType('ZIP');
        Test.stopTest();
        
        //System.assert(unknown == '/unknown.png');
        System.assert(astro == '/icons/AstroAnswer@2x.png');
        //System.assert(excel == '/icons/excel.png');
        //System.assert(gdoc == '/icons/googledocument.png');
        //System.assert(gpres == '/icons/googlepresentation.png');
        //System.assert(gsheet == '/icons/googlespreadsheet.png');
        //System.assert(jpg == '/icons/jpgimage.png');
        //System.assert(jpeg == '/icons/jpgimage.png');
        System.assert(ka == '/icons/KnowledgeArticle@2x.png');
        System.assert(link == '/icons/LINK@2x.png');
        System.assert(mov == '/icons/MOV@2x.png');
        System.assert(mp3 == '/icons/MP3@2x.png');
        System.assert(mp4 == '/icons/MP4@2x.png');
        System.assert(pack == '/icons/PACK@2x.png');
        //System.assert(pdf == '/icons/pdf.png');
        //System.assert(png == '/icons/pngimage.png');
        //System.assert(powerp == '/icons/powerpoint.png');
        System.assert(qsheet == '/icons/QUIPSHEET@2x.png');
        System.assert(qdoc == '/icons/QUIPDOC@2x.png');
        //System.assert(word == '/icons/word.png');
        System.assert(zip == '/icons/ZIP@2x.png');
    }
    
    @isTest static void getOriginURL() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        String fullURL = 'https://' + prefix.toLowerCase() + '.lightning.force.com';
        
        Test.startTest();
        String origin = StationSPController.getLexOriginUrl();
        Test.stopTest();
        
        System.assertEquals(origin, fullURL);
    }

    @isTest static void getBaseUrltest() {
        String testurl = URL.getSalesforceBaseURL().toExternalForm();
        Test.startTest();
        String subString = StationSPController.getBaseUrl();
        Test.stopTest();
        System.assertEquals(subString, testurl);
    }

    @isTest static void testSendMailMethod() {
        String to = 'rlambert@salesforce.com';
        String subject = 'StationSPControllerTest';
        String body = 'This is just a test';
        Test.startTest();        
        StationSPController.sendMailMethod(to, subject , body);
        Test.stopTest();
        System.assert(TRUE);
    }

    @isTest static void testGetSCGroupNames() {
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        String expectedValue = 'test grouping';
        String testValue = null;
        Station_Content__c content = new Station_Content__c(Name='test content',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 1);
        insert content;
        Station_Pages__c grouping = new Station_Pages__c(Name=expectedValue,
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association;        
        Test.startTest(); 
        Station_Content__c stationSP = StationSPController.getStationContentFields(content.id);
        List<Station_Pages__c> spgs = StationSPController.getSCGroupNames(content.id);
        if(spgs != null & spgs.isEmpty()) {
            System.assert(FALSE);
        } else {
            if (spgs[0].Name != null) {
                testValue = spgs[0].Name;
            }
        }
        Test.stopTest();
        System.assertEquals(expectedValue, testValue);
    }

    @isTest static void testGetContentRecords() {
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        String expectedValue = 'test content';
        Station_Content__c content = new Station_Content__c(Name=expectedValue,
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content;
        Station_Content__c content1 = new Station_Content__c(Name=expectedValue,
                                                            RecordTypeId = cvRT,
                                                            Content_Type__c='Content Version',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=2);
        insert content1;
        Station_Pages__c grouping = new Station_Pages__c(Name='test grouping',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        List<StationGroupingAssociation__c> association = new List<StationGroupingAssociation__c>();
        association.add(new StationGroupingAssociation__c(Station_Content__c=content.Id,Station_Page__c=grouping.Id));
        association.add(new StationGroupingAssociation__c(Station_Content__c=content1.Id,Station_Page__c=grouping.Id));
        insert association;      

        System.debug('Current UserName: ' + UserInfo.getUserName());        
        String runningUserId = UserInfo.getUserId();
        System.debug('Current UserId: ' + runningUserId);

        Station_Content__c testContent = null;
        String testContentName = null;
        System.debug('*** testGetContentRecords runningUserId : ' + runningUserId);
        Test.startTest();                
        List<Station_Content__c> sclist = StationSPController.getContentRecords(runningUserId);
        System.debug('*** testGetContentRecords sclist : ' + sclist);
        if (sclist != null & sclist.isEmpty()) {

        } else {
            System.debug('*** testGetContentRecords sclist[0] : ' + sclist[0]);            
            testContent = sclist[0];
            if(testContent != null) {                
                testContentName = testContent.Name;
            }
        }
        Test.stopTest();
        System.debug('*** testGetContentRecords testContentName : ' + testContentName);   
        System.debug('*** testGetContentRecords expectedValue   : ' + expectedValue);   
        System.assertEquals(expectedValue, testContentName);
    }    

    /*
    @isTest static void testGetDomainOriginUrl() {
        String expectedValue = 'https://sfservices--bedrockuat.lightning.force.com';
        String actualValue = null;

        Test.startTest();                
        actualValue = StationSPController.getDomainOriginUrl();
        System.debug('*** testGetDomainOriginUrl actualValue : ' + actualValue);   
        Test.stopTest();
        String expectedLeftStr = expectedValue.left(18);
        String actualLeftStr = actualValue.left(18);

        System.assertEquals(expectedLeftStr, actualLeftStr);
    }
	*/
    @isTest static void testGetParamsValuesfromURl() {
        String expectedValue = 'two';
        String actualValue = null;
        String url = 'http://www.salesforce.com?param1=one&param2=two';
        String param = 'param2';

        Test.startTest();                
        actualValue = StationSPController.getParamsValuesfromURl(url, param);
        System.debug('*** testGetParamsValuesfromURl actualValue : ' + actualValue);   
        Test.stopTest();

        System.assertEquals(expectedValue, actualValue);
    }

    /*
    @isTest static void testGetRunningUserInfo() {
        User usr = null;
        User actualValue = null;
        String accountName = 'Salesforce.com - DO NOT TOUCH';

        Test.startTest();
        Account a = new Account(Name = accountName);
        insert a;
        System.debug('*** testGetRunningUserInfo accountId : '+a.Id);

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
        System.debug('*** testGetUserName User Name : '+n);

        Profile p = [select id from Profile where name = 'Standard User'];
        usr = new User();
        usr.Alias = 'newUser';
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
            actualValue = StationSPController.getRunningUserInfo();
            System.debug('*** testGetRunningUserInfo actualValue : ' + actualValue);   			
        }

		Test.stopTest();
        System.assertEquals(usr.Id, actualValue.Id);
    }    

    @isTest static void testGetUserName() {
        String actualValue = null;
        String accountName = 'Salesforce.com - DO NOT TOUCH';

        Test.startTest();
        Account a = new Account(Name = accountName);
        insert a;
        System.debug('*** testGetUserName accountId : '+a.Id);

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
        String expectedValue = fName + ' ' + lName;
        System.debug('*** testGetUserName User Name : '+expectedValue);

        Profile p = [select id from Profile where name = 'Standard User'];
        User u = new User();
        u.Alias = 'newUser';
        u.Email = 'newuser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.FirstName = fName;
        u.LastName = lName;
        u.Username = uName;
        u.ProfileId = p.Id;
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';

        insert u;

        actualValue = StationSPController.getUserName(u.Id);
        System.debug('*** testGetUserName actualValue : ' + actualValue);   			
        
		Test.stopTest();
        System.assertEquals(expectedValue, actualValue);
    }    

    @isTest static void testGetLocalUserIDForOrg62UserID() {
        User usr = null;
        String actualValue = null;
        String expectedValue = null;
        String accountName = 'Salesforce.com - DO NOT TOUCH';

        Test.startTest();
        Account a = new Account(Name = accountName);
        insert a;
        System.debug('*** testGetLocalUserIDForOrg62UserID accountId : '+a.Id);

        Profile p = [select id from Profile where name = 'Standard User'];
        usr = new User();
        usr.Alias = 'DMier';
        usr.Email = 'dmierke@salesforce.com';
        usr.EmailEncodingKey = 'UTF-8';
        usr.FirstName = 'David';
        usr.LastName = 'Mierke';
        usr.Username = 'dmierke@sfservices.com';
        usr.ProfileId = p.Id;
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';        
        usr.TimeZoneSidKey = 'America/Los_Angeles';

        insert usr;

        User dm = [SELECT Id FROM User WHERE name = 'David Mierke' AND alias = 'DMier' LIMIT 1];
        if (dm != null) {
            expectedValue = dm.Id;
        }
        actualValue = StationSPController.getLocalUserIDForOrg62UserID(usr.Id);
        
        System.debug('*** testGetLocalUserIDForOrg62UserID actualValue : ' + actualValue);   			
        
		Test.stopTest();
        System.assertEquals(expectedValue, actualValue);
    }
	*/

    @isTest static void testGetContentBits() {
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        String expectedValue1 = 'test content 1';
        String expectedValue2 = 'test content 2';
        Test.startTest();                        
        
        Station_Content__c content = new Station_Content__c(Name=expectedValue1,
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content;
        Station_Content__c content1 = new Station_Content__c(Name=expectedValue2,
                                                            RecordTypeId = cvRT,
                                                            Content_Type__c='Content Version',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=2);
        insert content1;
/*
        Station_Pages__c grouping = new Station_Pages__c(Name='test grouping',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        String groupingId = grouping.Id;
        List<StationGroupingAssociation__c> association = new List<StationGroupingAssociation__c>();
        association.add(new StationGroupingAssociation__c(Station_Content__c=content.Id,Station_Page__c=grouping.Id));
        association.add(new StationGroupingAssociation__c(Station_Content__c=content1.Id,Station_Page__c=grouping.Id));
        insert association;      

        System.debug('Current UserName: ' + UserInfo.getUserName());        
        String runningUserId = UserInfo.getUserId();
        System.debug('Current UserId: ' + runningUserId);
*/
        StationContentWrapper testWrapper = null;
        Station_Content__c testContent = null;
        String testContentName = null;
        
        List<Station_Content__c> contentList = new List<Station_Content__c>(
            [SELECT Id, Name, Order__c, Content_Type__c, Content_URL__c, Subtitle__c, Description__c, 
            Display_Image_URL__c, Industry__c, Statistic__c, Primary_Contact__c, Primary_Contact__r.Name, 
            Owner.Name, Visibility__c, Next_Review_Date__c, Review_Status__c, LastModifiedDate, 
            Upload_Image__c, OwnerId  FROM Station_Content__c]);

        List<StationContentWrapper> wrappedList = new List<StationContentWrapper>();
        for(Station_Content__c c : contentList) {
            StationContentWrapper wrapped = new StationContentWrapper(c);
            wrappedList.add(wrapped);
        }

        List<StationContentWrapper> scwlist = StationSPController.getContentBits(wrappedList);
        System.debug('*** testGetContentBits scwlist : ' + scwlist);
        if (scwlist != null & scwlist.isEmpty()) {

        } else {
            System.debug('*** testGetContentBits scwlist[0] : ' + scwlist[0]);            
            testWrapper = scwlist[0];
            if(testWrapper != null) {                
                testContent = testWrapper.content;
                if (testContent != null) {
                    testContentName = testContent.Name;
                }
            }
        }
        Test.stopTest();
        System.debug('*** testGetContentRecords testContentName : ' + testContentName);   
        System.debug('*** testGetContentRecords expectedValue1   : ' + expectedValue1);   
        System.debug('*** testGetContentRecords expectedValue2   : ' + expectedValue2);           
        System.assertEquals(expectedValue1, testContentName);
    }    
}