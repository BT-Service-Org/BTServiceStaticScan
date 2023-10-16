trigger PACustSurvey on PA_Customer_Survey__c (before insert) {

    PACustomerSurveyHandler.FillPAOnboardingID(trigger.new);
}