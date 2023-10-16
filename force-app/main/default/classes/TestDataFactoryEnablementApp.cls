@isTest
public with sharing class TestDataFactoryEnablementApp {
    
    public static Enablement_Item__c createEnablementItem() {
        Enablement_Item__c enItem = new Enablement_Item__c();
        enItem.Name = 'test enablement item';
        enItem.Status__c = 'Active';
        enItem.Category__c = 'Trailhead';
        enItem.Expected_Hours_to_Complete__c = 10;
        return enItem;
    }

    public static Enablement_Domain__c createEnablementDomain() {
        Enablement_Domain__c enDomain = new Enablement_Domain__c();
        enDomain.Name = 'test domain';
        enDomain.Active__c = true;
        return enDomain;
    }

    public static Enablement_Item_Domain__c createEnablementItemDomain(String domainId, String enItemId) {
        Enablement_Item_Domain__c enItemDomain = new Enablement_Item_Domain__c();
        enItemDomain.Onboarding_Domain__c = domainId;
        enItemDomain.Learning__c = enItemId;
        enItemDomain.Status__c = 'Active';
        return enItemDomain;
    }

    public static Enablement_Exception__c createEnablementException(String domainId, String type, String basis, String basisValue) {
        Enablement_Exception__c enException = new Enablement_Exception__c();
        enException.Learning_Domain__c = domainId;
        enException.Type__c = type;
        enException.Basis__c = basis;
        enException.Value__c = basisValue;
        return enException;
    }


    public static Enablement_Journey__c createEnablementJourney(Boolean isTemplate) {
        Enablement_Journey__c enJourney = new Enablement_Journey__c();
        enJourney.Name = 'test journey';
        enJourney.Contributor_Type__c = 'Individual Contributor';
        enJourney.Worker_Type__c = 'Remote';
        enJourney.Region__c = 'AMER';
        enJourney.Hire_Type__c = 'New Hire';
        enJourney.Job_Level__c = '6';

        enJourney.Status__c = 'On Ramp';
        enJourney.IsActive__c = true;

        if(isTemplate) {
            enJourney.recordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Template').getRecordTypeId();
        } else {
            enJourney.recordTypeId = Schema.SObjectType.Enablement_Journey__c.getRecordTypeInfosByDeveloperName().get('Enablement_Journey').getRecordTypeId();
        }
        
        return enJourney;
    }

    public static Enablement_Journey_Domain__c createEnablementJourneyDomain(String enJourneyId, String domainId) {
        Enablement_Journey_Domain__c enJourneyDomain = new Enablement_Journey_Domain__c();
        enJourneyDomain.Enablement_Domain__c = domainId;
        enJourneyDomain.Enablement_Journey__c = enJourneyId;
        enJourneyDomain.Is_Active__c = true;
        return enJourneyDomain;
    }

    public static Enablement_Activity_Group__c createEnablementActivityGroup(String enJourneyId) {
        Enablement_Activity_Group__c enActGroup = new Enablement_Activity_Group__c();
        enActGroup.Name = 'test group';
        enActGroup.Enablement_Journey__c = enJourneyId;
        enActGroup.Days_Until_Start__c = 1;
        enActGroup.Days_To_Complete__c = 10;
        return enActGroup;
    }

    public static Enablement_Activity__c createEnablementActivity(String enActGroupId, String enItemId, String status) {
        Enablement_Activity__c enAct = new Enablement_Activity__c();
        enAct.Name = 'test activity';
        enAct.Activity_Group__c = enActGroupId;
        enAct.Days_Until_Start__c = 1;
        enAct.Days_To_Complete__c = 10;
        enAct.Learning__c = enItemId;
        enAct.Hours_Required__c = 10;
        enAct.Priority__c = 'High';
        enAct.Status__c = status;
        return enAct;
    }

    public static Stakeholder__c createStakeholder() {
        Stakeholder__c stkholder = new Stakeholder__c();
        stkholder.Name = 'Manager';
        stkholder.Type__c = 'Enablement';
        return stkholder;
    }

    public static Enablement_RACI__c createEnablementRACI(String enActId, String stkholderId) {
        Enablement_RACI__c enRACI = new Enablement_RACI__c();
        enRACI.Enablement_Activity__c = enActId;
        enRACI.Stakeholder_Role__c = stkholderId;
        enRACI.RACI__c = 'R - Responsible';
        return enRACI;
    }

}