@isTest
public class The_Station_inlineEditCtrlTest {
	
    @isTest
    public static void fetchAssociationTest(){
        Test.startTest();
        The_Station_inlineEditCtrl.fetchAssociation('a4aL0000000MQuWIAW');
        Test.stopTest();
    }
    
    @isTest
    public static void saveAssociationTest(){
        List<StationGroupingAssociation__c > lstassociation = new List<StationGroupingAssociation__c>();
        
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
                                                                                      Station_Page__c=grouping.Id,
                                                                                     Order__c=1);
        insert association;
        StationGroupingAssociation__c association1 = new StationGroupingAssociation__c(Station_Content__c=content1.Id,
                                                                                      Station_Page__c=grouping.Id,
                                                                                      Order__c=2);
        insert association1;
        
        association.Order__c=3;
        association1.Order__c = 4;
        lstassociation.add(association);
        
        Test.startTest();
        The_Station_inlineEditCtrl.saveAssociation(lstassociation);
        Test.stopTest();
        
        System.assert(association.Order__c == 3, 'association order update failed');
        System.assert(association1.Order__c == 4, 'association1 order update failed');
    }
    
    @isTest
    public static void delteAssociationBIdTest() {
        List<StationGroupingAssociation__c > lstassociation = new List<StationGroupingAssociation__c>();
        
        Id cvRT = Schema.SObjectType.Station_Content__c.getRecordTypeInfosByDeveloperName().get('Standard_Content').getRecordTypeId();
        
        Station_Content__c content = new Station_Content__c(Name='test content',
                                                            RecordTypeId = cvRT,
                                                            Content_Type__c='Content Version',
                                                            Content_URL__c='http://contenttesturl.com/testurl',
                                                            Order__c=1);
        insert content;
        Station_Pages__c grouping = new Station_Pages__c(Name='test grouping',
                                                       Cloud_Product__c='Advisory Services',
                                                       Tab_Name__c='test tab');
        insert grouping;
        StationGroupingAssociation__c association = new StationGroupingAssociation__c(Station_Content__c=content.Id,
                                                                                      Station_Page__c=grouping.Id,
                                                                                     Order__c=1);
        insert association;
        
        Test.startTest();
        The_Station_inlineEditCtrl.delteAssociationBId(association.id);
        Test.stopTest();
    }
}