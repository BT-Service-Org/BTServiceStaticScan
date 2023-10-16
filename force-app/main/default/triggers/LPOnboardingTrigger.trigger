/*****************************************
* File: LPOnboardingTrigger
* Author: William Steele-Salesforce PA
* Description: Contact Trigger
******************************************/
trigger LPOnboardingTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Util.inFutureContext == false) {
        IXTriggerDispatcher.Run(new LPOnboardingTriggerHandler());
    }
}