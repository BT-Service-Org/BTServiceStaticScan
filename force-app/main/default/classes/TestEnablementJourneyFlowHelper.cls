//This is the test class for EnablementJourneyFlowHelper
@isTest
public with sharing class TestEnablementJourneyFlowHelper {
    
    @isTest
    public static void TestCloneEnablementJourney() {

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
        Enablement_Journey__c enJourney =  TestDataFactoryEnablementApp.createEnablementJourney(true);
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
        Stakeholder__c stkholder =  TestDataFactoryEnablementApp.createStakeholder();
        insert stkholder;
        Enablement_RACI__c enRACI =  TestDataFactoryEnablementApp.createEnablementRACI(enAct1.Id, stkholder.Id);
        insert enRACI;

        Test.startTest();

        EnablementJourneyFlowHelper.FlowInputForClone flowInput = new EnablementJourneyFlowHelper.FlowInputForClone();
        flowInput.originalEnablementJourneyId = enJourney.Id;
        flowInput.isTemplate = false;
        flowInput.newEnablementJourneyName = 'test journey 123';
        flowInput.journeyStartDate = System.today();
        flowInput.region = 'AMER';
        flowInput.hireType = 'New Hire';
        flowInput.workerType = 'Remote';
        flowInput.contributorType = 'Individual Contributor';
        flowInput.jobLevel = '8';
        List<EnablementJourneyFlowHelper.FlowInputForClone> flowInputs = new List<EnablementJourneyFlowHelper.FlowInputForClone>();
        flowInputs.add(flowInput);
        EnablementJourneyFlowHelper.cloneEnablementJourney(flowInputs);

        //Create template
        flowInput.isTemplate = true;
        EnablementJourneyFlowHelper.cloneEnablementJourney(flowInputs);

        Test.stopTest();

    }
}