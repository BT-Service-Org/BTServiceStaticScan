//Test class for LearningExceptionsHandler
@isTest
public with sharing class TestLearningExceptionsHandler {

    @isTest
    public static void testApplyLearningExceptions() {
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
        List<LearningExceptionsHandler.FlowInputForExceptions> flowInputs = new List<LearningExceptionsHandler.FlowInputForExceptions>();
        LearningExceptionsHandler.FlowInputForExceptions flowInput = new LearningExceptionsHandler.FlowInputForExceptions();
        flowInput.enablementJourneyId = enJourney.Id;
        flowInputs.add(flowInput);

        LearningExceptionsHandler.applyLearningExceptions(flowInputs);

        Test.stopTest();

    }

}