//Test class for ActivityGroupsTemplateController
@isTest
public with sharing class TestActivityGroupsTemplateController {
    @isTest
    public static void TestGetActivityGroups() {
        Enablement_Item__c enItem = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem.Id);
        insert enItemDomain;
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(false);
        insert enJourney;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourney.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourney.Id);
        insert enActGroup;


        Test.startTest();
        ActivityGroupsTemplateController.getActivityGroups(enActGroup.Id);
        Test.stopTest();

    }
}