/*****************************************
* File: LPOnboardingPrepareTrigger
* Author: William Steele-Salesforce PA
* Description: Trigger Handler logic for PA_Onboarding__c records--to add all necessary components
******************************************/
trigger LPOnboardingPrepareTrigger on PA_Onboarding__c ( after insert) {
    IXTriggerDispatcher.Run(new LPOnboardingPrepareTriggerHandler());
}