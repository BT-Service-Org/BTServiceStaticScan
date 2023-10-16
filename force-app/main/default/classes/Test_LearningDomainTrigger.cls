@isTest (SeeAllData=true)
private class Test_LearningDomainTrigger {
    private static testMethod void TestCreateLDEARecord(){
        PA_Onboarding__c paonboard = [select id from PA_Onboarding__c order by CreatedDate desc limit 1];
        Learning_Domain__c ld = new Learning_Domain__c();
        ld.Target_End_Date__c = Date.today().addDays(90);
        ld.Category__c = 'Technical Skill';
        ld.Skill__c = 'EA Specialization';
        ld.PA_Onboarding__c = paonboard.Id;
        test.startTest();
        insert ld;
        ld.Target_End_Date__c = Date.today().addDays(80);
        update ld;
        test.stopTest();
    }
}