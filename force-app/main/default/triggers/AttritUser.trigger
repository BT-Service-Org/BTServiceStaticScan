trigger AttritUser on PA_Onboarding__c (after update) {
    
    LPDeactivateUser lp = new LPDeactivateUser();
    
    lp.attrit([select Id,Name,Candidate__c,Status__c from PA_Onboarding__c where Id in:Trigger.new]);
       
}