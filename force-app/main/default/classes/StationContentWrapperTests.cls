@isTest
public class StationContentWrapperTests {
    @isTest static void wrapperCompare() {
        List<StationContentWrapper> wrappedList = new List<StationContentWrapper>();
        Id recordTypeId = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Success_Program').getRecordTypeId();
        
        Station_Content__c content = new Station_Content__c(Name='test content',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c = 'Success Program',
                                                            Content_URL__c = 'http://contenttesturl.com/testurl',
                                                            Order__c = 2);
        
        insert content;
        StationContentWrapper wrapped = new StationContentWrapper(content);
        wrappedList.add(wrapped);
        
        Station_Content__c content1 = new Station_Content__c(Name='test content 1',
                                                            RecordTypeId = recordTypeId,
                                                            Content_Type__c='Success Program',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content1;
        StationContentWrapper wrapped1 = new StationContentWrapper(content1);
        wrappedList.add(wrapped1);
        
        Test.startTest();
        
        wrappedList.sort();

        Test.stopTest();
        
        System.assert(wrappedList.isEmpty() == FALSE, 'Content query return zero results');
        StationContentWrapper first = (StationContentWrapper)wrappedList.get(0);
        System.assert(first.content.Order__c == 1, 'Incorrect Order value');
    }
}