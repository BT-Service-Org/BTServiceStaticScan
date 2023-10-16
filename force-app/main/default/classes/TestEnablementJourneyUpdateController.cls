//Test class for EnablementJourneyUpdateController
@isTest

public with sharing class TestEnablementJourneyUpdateController {
    @isTest
    public static void TestupdateEnablementJourney_CriteriaBased() {

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
        Enablement_Journey__c enJourneyTemplate =  TestDataFactoryEnablementApp.createEnablementJourney(true);
        insert enJourneyTemplate;

        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourneyTemplate.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourneyTemplate.Id);
        insert enActGroup;
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Started');
        enAct1.Publish__c = true;
        insert enAct1;
        Enablement_Activity__c enAct2 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Required');
        insert enAct2;
        Enablement_Activity__c enAct3 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'In Progress');
        insert enAct3;
        Stakeholder__c stkholder =  TestDataFactoryEnablementApp.createStakeholder();
        insert stkholder;
        Enablement_RACI__c enRACI =  TestDataFactoryEnablementApp.createEnablementRACI(enAct1.Id, stkholder.Id);
        insert enRACI;

        insert new Enablement_Source__c(Enablement_Journey__c=enJourney.Id, Parent_Template__c=enJourneyTemplate.Id, Unique_Id__c = enJourney.Id +'_'+enJourneyTemplate.Id);

        Test.startTest();

        EnablementJourneyUpdateController.FlowInputForUpdate flowInput = new EnablementJourneyUpdateController.FlowInputForUpdate();
        flowInput.originalEnablementJourneyId = enJourneyTemplate.Id;
        flowInput.isCriteriaBased = true;
        flowInput.publishSpecifiedActivities = false;

        List<EnablementJourneyUpdateController.FlowInputForUpdate> flowInputs = new List<EnablementJourneyUpdateController.FlowInputForUpdate>();
        flowInputs.add(flowInput);
        EnablementJourneyUpdateController.updateEnablementJourney(flowInputs);

        Test.stopTest(); 
    
    }

    @isTest
    public static void TestupdateEnablementJourney_RelatedJourneys() {

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
        Enablement_Journey__c enJourneyTemplate =  TestDataFactoryEnablementApp.createEnablementJourney(true);
        insert enJourneyTemplate;
        Enablement_Journey_Domain__c enJourneyDomain =  TestDataFactoryEnablementApp.createEnablementJourneyDomain(enJourneyTemplate.Id, enDomain.Id);
        insert enJourneyDomain;
        Enablement_Activity_Group__c enActGroup =  TestDataFactoryEnablementApp.createEnablementActivityGroup(enJourneyTemplate.Id);
        insert enActGroup;
        Enablement_Activity__c enAct1 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Started');
        enAct1.Publish__c = true;
        insert enAct1;
        Enablement_Activity__c enAct2 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'Not Required');
        insert enAct2;
        Enablement_Activity__c enAct3 =  TestDataFactoryEnablementApp.createEnablementActivity(enActGroup.Id, enItem.Id, 'In Progress');
        insert enAct3;
        Stakeholder__c stkholder =  TestDataFactoryEnablementApp.createStakeholder();
        insert stkholder;
        Enablement_RACI__c enRACI =  TestDataFactoryEnablementApp.createEnablementRACI(enAct1.Id, stkholder.Id);
        insert enRACI;

        insert new Enablement_Source__c(Enablement_Journey__c=enJourney.Id, Parent_Template__c=enJourneyTemplate.Id, Unique_Id__c = enJourney.Id +'_'+enJourneyTemplate.Id);

        Test.startTest();

        EnablementJourneyUpdateController.FlowInputForUpdate flowInput = new EnablementJourneyUpdateController.FlowInputForUpdate();
        flowInput.originalEnablementJourneyId = enJourneyTemplate.Id;
        flowInput.isCriteriaBased = false;
        flowInput.publishSpecifiedActivities = true;
        List<EnablementJourneyUpdateController.FlowInputForUpdate> flowInputs = new List<EnablementJourneyUpdateController.FlowInputForUpdate>();
        flowInputs.add(flowInput);
        EnablementJourneyUpdateController.updateEnablementJourney(flowInputs);

        Test.stopTest(); 
    
    }
}