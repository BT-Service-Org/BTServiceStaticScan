@isTest
public class The_Station_CollectionContentTest {
    @isTest static void getCollectionContentRecordsTest() {
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
        List<Object>LastcontentList = The_Station_CollectionContentController.getCollectionContentRecords(groupingId,'Last Updated',0);
        List<Object>CreatecontentList = The_Station_CollectionContentController.getCollectionContentRecords(groupingId,'Created Date',0);
        List<Object>AlphacontentList = The_Station_CollectionContentController.getCollectionContentRecords(groupingId,'Alphabetical',0);
        List<Object>nullList = The_Station_CollectionContentController.getCollectionContentRecords('','',0);
        Test.stopTest();
        System.debug('List size '+LastcontentList.size());
        System.assert(LastcontentList.isEmpty() == FALSE, 'Content query return zero results');
        System.assert(CreatecontentList.isEmpty() == FALSE, 'Content query return zero results');
        System.assert(AlphacontentList.isEmpty() == FALSE, 'Content query return zero results');
        System.assert(nullList.isEmpty() == TRUE, 'Blank query returned results');
        The_Station_CollectionContentWrapper first = (The_Station_CollectionContentWrapper)LastcontentList.get(0);
        System.assert(first.content.Content_Type__c == 'Success Program', 'Incorrect Content Type');
        System.assert(first.content.Content_URL__c == 'http://contenttesturl.com/testurl', 'Incorrect Content URL');
        System.assert(first.content.Order__c == 1, 'Incorrect Order value');
        first = (The_Station_CollectionContentWrapper)CreatecontentList.get(0);
        System.assert(first.content.Content_Type__c == 'Success Program', 'Incorrect Content Type');
        System.assert(first.content.Content_URL__c == 'http://contenttesturl.com/testurl', 'Incorrect Content URL');
        System.assert(first.content.Order__c == 1, 'Incorrect Order value');
        first = (The_Station_CollectionContentWrapper)AlphacontentList.get(0);
        System.assert(first.content.Content_Type__c == 'Success Program', 'Incorrect Content Type');
        System.assert(first.content.Content_URL__c == 'http://contenttesturl.com/testurl', 'Incorrect Content URL');
        System.assert(first.content.Order__c == 1, 'Incorrect Order value');

    }
    @isTest static void getLexOriginUrlTest() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        String fullURL = 'https://' + prefix.toLowerCase() + '.lightning.force.com';
        
        Test.startTest();
        String origin = The_Station_CollectionContentController.getLexOriginUrl();
        Test.stopTest();
        
        System.assertEquals(origin, fullURL);
    }
    @isTest static void getContentTests() {
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        Id spRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id colRT = Schema.SObjectType.Station_Pages__c.getRecordTypeInfosByDeveloperName().get('Collection').getRecordTypeId();
        
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
                                                       Tab_Name__c='test tab',
                                                       RecordTypeId = colRT);
        insert grouping;
        String groupingId = grouping.Id;
        String contentId = content.Id;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association;
        StationGroupingAssociation__c association1 = new StationGroupingAssociation__c(Station_Content__c=content1.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association1;
        
        List<Object>contentList = The_Station_CollectionContentController.getCollectionContentRecords(groupingId,'Last Updated',0);
        String contentJson = JSON.serialize(contentList);

        Test.startTest();
        List<The_Station_CollectionContentWrapper> contentPieces = The_Station_CollectionContentController.getContentPieces(contentJSON);
        The_Station_CollectionContentWrapper contentRecord = The_Station_CollectionContentController.getContentRecord(contentId);
        // The_Station_CollectionContentWrapper nullRecord = The_Station_CollectionContentController.getContentRecord('');
        Integer num1 = The_Station_CollectionContentController.getCollectionNumber(contentId);
        Integer numnull = The_Station_CollectionContentController.getCollectionNumber('');
        Test.stopTest();
        
        System.assert(contentPieces.isEmpty() == FALSE, 'Content query return zero results');
        // System.assert(nullRecord == null, 'Blank query returned results');
        System.assert(contentRecord.content.Content_Type__c == 'Content Version', 'Incorrect Content Type');
        System.assert(contentRecord.content.Content_URL__c == 'http://contenttesturl.com/testurl', 'Incorrect Content URL');
        System.assert(contentRecord.content.Order__c == 1, 'Incorrect Order value');
        System.assert(num1 == 1, 'Incorrect collection number');
        // System.assert(numnull == null, 'Null value did not return null');

    }
    @isTest static void getUserNameTest() {

        String accountName = 'Salesforce.com - DO NOT TOUCH';
        Account a = new Account(Name = accountName);
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, FirstName='Jane', Title='Test',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@teststationwork.com');

        insert u;

        String userId= u.Id;
        Test.startTest();
        String returnName = The_Station_CollectionContentController.getUserName(userId);
        System.assertEquals(returnName, 'Jane Testing');
        Test.stopTest();

    }

    @isTest static void getRunningUserInfoTest(){
       String userId = UserInfo.getUserId();
       Test.startTest();
       User u = The_Station_CollectionContentController.getRunningUserInfo();
       Test.stopTest();
       System.assertEquals(u.Id, userId);
    }


    @isTest static void getTotalItemsTest(){
        
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        Id spRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        Id colRT = Schema.SObjectType.Station_Pages__c.getRecordTypeInfosByDeveloperName().get('Collection').getRecordTypeId();
        
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
                                                       Tab_Name__c='test tab',
                                                       RecordTypeId = colRT);
        insert grouping;
        // String groupingId = grouping.Id;
        // String contentId = content.Id;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association;
        StationGroupingAssociation__c association1 = new StationGroupingAssociation__c(Station_Content__c=content1.Id,
                                                                                      Station_Page__c=grouping.Id);
        insert association1;

        Test.startTest();
        Integer result = The_Station_CollectionContentController.getTotalItems(grouping.Id);
        Test.stopTest();
        System.assertEquals(2, result, 'Total items do not match');

     }


     @isTest static void getContentSearchTests() {
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
        String searchTerms = 'test';
        List<Object>LastcontentList = The_Station_CollectionContentController.getCollectionContentRecordsWithSearch(searchTerms,groupingId,'Last Updated',0);
        List<Object>CreatecontentList = The_Station_CollectionContentController.getCollectionContentRecordsWithSearch(searchTerms,groupingId,'Created Date',0);
        List<Object>AlphacontentList = The_Station_CollectionContentController.getCollectionContentRecordsWithSearch(searchTerms,groupingId,'Alphabetical',0);
        //List<Object>nullList = The_Station_CollectionContentController.getCollectionContentRecordsWithSearch('','','',0);
        Test.stopTest();
        System.debug('Returned List'+LastcontentList);
        System.assert(LastcontentList == null, '');
        System.assert(CreatecontentList == null, '');
        System.assert(AlphacontentList == null, '');
        //System.assert(nullList.isEmpty() == TRUE, 'Blank query returned results');

    }

}