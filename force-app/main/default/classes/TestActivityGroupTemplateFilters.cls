//Test class for ActivityGroupTemplateFiltersController
@isTest

public with sharing class TestActivityGroupTemplateFilters {
    @isTest
    public static void TestGetEnablementItemsList_WithTemplate() {
        Enablement_Item__c enItem = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem.Id);
        insert enItemDomain;
        Enablement_Exception__c enException1 =  TestDataFactoryEnablementApp.createEnablementException(enItemDomain.Id, 'Restriction', 'Contributor Type', 'Individual Contributor'); 
        insert enException1;
        Enablement_Exception__c enException2 =  TestDataFactoryEnablementApp.createEnablementException(enItemDomain.Id, 'Exemption', 'Worker Type', 'Remote');
        insert enException2;
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
        Stakeholder__c stkholder =  TestDataFactoryEnablementApp.createStakeholder();
        insert stkholder;
        Enablement_RACI__c enRACI =  TestDataFactoryEnablementApp.createEnablementRACI(enAct1.Id, stkholder.Id);
        insert enRACI;

        Test.startTest();
        //"notgroup" selected show option
        ActivityGroupTemplateFiltersController.getEnablementItemsList(enActGroup.Id, enJourney.id, enActGroup.Id, enDomain.Id, 'Trailhead', 'High', 'notgroup');
        //"group" selected show option
        ActivityGroupTemplateFiltersController.getEnablementItemsList(enActGroup.Id, enJourney.id, enActGroup.Id, enDomain.Id, 'Trailhead', 'High', 'group');
        Test.stopTest();
    }

    @isTest
    public static void TestGetEnablementItemsList_WithoutTemplate() {
        Enablement_Item__c enItem = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem.Id);
        insert enItemDomain;
        Enablement_Exception__c enException1 =  TestDataFactoryEnablementApp.createEnablementException(enItemDomain.Id, 'Restriction', 'Contributor Type', 'Individual Contributor'); 
        insert enException1;
        Enablement_Exception__c enException2 =  TestDataFactoryEnablementApp.createEnablementException(enItemDomain.Id, 'Exemption', 'Worker Type', 'Remote');
        insert enException2;
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
        Stakeholder__c stkholder =  TestDataFactoryEnablementApp.createStakeholder();
        insert stkholder;
        Enablement_RACI__c enRACI =  TestDataFactoryEnablementApp.createEnablementRACI(enAct1.Id, stkholder.Id);
        insert enRACI;

        Test.startTest();
        //"notgroup" selected show option
        ActivityGroupTemplateFiltersController.getEnablementItemsList(enActGroup.Id, '', enActGroup.Id, enDomain.Id, 'Trailhead', 'High', 'notgroup');
        //"group" selected show option
        ActivityGroupTemplateFiltersController.getEnablementItemsList(enActGroup.Id, '', enActGroup.Id, enDomain.Id, 'Trailhead', 'High', 'group');
        Test.stopTest();
    }


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
        ActivityGroupTemplateFiltersController.getActivityGroups(enJourney.Id);
        Test.stopTest();

    }

    @isTest
    public static void TestGetAllTemplates() {

        Enablement_Item__c enItem = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem.Id);
        insert enItemDomain;
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(true);
        insert enJourney;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourney.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourney.Id);
        insert enActGroup;

        Test.startTest();
        ActivityGroupTemplateFiltersController.getAllTemplates();
        Test.stopTest();

    }

    @isTest
    public static void TestgetAllDomains() {

        Enablement_Item__c enItem = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem.Id);
        insert enItemDomain;
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(true);
        insert enJourney;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourney.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourney.Id);
        insert enActGroup;

        Test.startTest();
        ActivityGroupTemplateFiltersController.getAllDomains(enActGroup.Id);
        Test.stopTest();

    }

    @isTest
    public static void TestAddActivities() {
        Enablement_Item__c enItem1 = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem1;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem1.Id);
        insert enItemDomain;
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(false);
        insert enJourney;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourney.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourney.Id);
        insert enActGroup;
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem1.Id, 'Not Started');
        insert enAct1;


        Test.startTest();
        List<String> selectedItems = new List<String>();
        selectedItems.add('{"publish":true,"enablementItemDomain":"Salesforce Global","enablementItemName":"'+enItem1.Name+'","enablementItemStatus":"Not Started","Id":"'+enItem1.Id+'","recordURL":"/'+enItem1.Id+'"}');
        selectedItems.add('{"publish":true,"enablementItemDomain":"Salesforce Global","enablementItemName":"'+enAct1.Name+'","enablementItemStatus":"Not Started","Id":"'+enAct1.Id+'","recordURL":"/'+enAct1.Id+'"}');
        ActivityGroupTemplateFiltersController.addActivities(enActGroup.Id, selectedItems);
        Test.stopTest();
    }

    @isTest
    public static void TestRemoveActivities() {
        Enablement_Item__c enItem1 = TestDataFactoryEnablementApp.createEnablementItem();
        insert enItem1;
        Enablement_Domain__c enDomain = TestDataFactoryEnablementApp.createEnablementDomain();
        insert enDomain;
        Enablement_Item_Domain__c enItemDomain = TestDataFactoryEnablementApp.createEnablementItemDomain(enDomain.Id, enItem1.Id);
        insert enItemDomain;
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(false);
        insert enJourney;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourney.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourney.Id);
        insert enActGroup;
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem1.Id, 'Not Started');
        insert enAct1;


        Test.startTest();
        List<String> enablementItemIds = new List<String> {enAct1.Id};
        ActivityGroupTemplateFiltersController.removeActivities(enActGroup.Id, enablementItemIds);
        Test.stopTest();
    }
}