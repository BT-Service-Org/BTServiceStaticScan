public with sharing class SupportCasesController {
@AuraEnabled
    public static List<Supportforce_Case__x> getSupportCases() {
        String runningUserEmail = UserInfo.getUserEmail();

        List <Supportforce_Case__x> cases;
        cases = [SELECT Subject__c, Case_Number__c,Date_Time_Opened__c,Last_Case_Owner_Comment_Time__c, Status__c,DisplayUrl,ContactEmail__c 
                FROM Supportforce_Case__x 
                WHERE ContactEmail__c = :runningUserEmail 
                ORDER BY Date_Time_Opened__c DESC NULLS LAST LIMIT 50 ];
        return cases;
    }
}