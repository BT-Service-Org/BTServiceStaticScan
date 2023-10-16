@isTest
public with sharing class TestActivityGroupController {
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
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Started');
        insert enAct1;
        Enablement_Activity__c enAct2 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Required');
        insert enAct2;
        Enablement_Activity__c enAct3 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'In Progress');
        insert enAct3;
        Enablement_Activity__c enAct4 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Completed');
        insert enAct4;
 

        Test.startTest();
        ActivityGroupController.getActivityGroups(enJourney.Id);
        Test.stopTest();

    }

    public static void TestGetActivityGroups_AllNotStarted() {
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
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Started');
        insert enAct1;
 

        Test.startTest();
        ActivityGroupController.getActivityGroups(enJourney.Id);
        Test.stopTest();

    }

    public static void TestGetActivityGroups_AllCompleted() {
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
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Completed');
        insert enAct1;

        Test.startTest();
        ActivityGroupController.getActivityGroups(enJourney.Id);
        Test.stopTest();

    }
}