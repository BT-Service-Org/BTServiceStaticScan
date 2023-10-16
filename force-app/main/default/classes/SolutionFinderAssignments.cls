public with sharing class SolutionFinderAssignments {

    @AuraEnabled
    public static List<User> getUsers() {
        return [SELECT Id, FederationIdentifier, FirstName, LastName
                FROM User
                WITH SECURITY_ENFORCED
                ORDER BY LastName, FirstName
                LIMIT 10000];
    }

    @AuraEnabled
    public static List<SolutionFinderAssignment> getAssignments(String userId) {
        List<SolutionFinderAssignment> assignments = new List<SolutionFinderAssignment>();
        for (Solution_Finder_Permission__c record :
                [SELECT Id, OwnerId, Option_Name__c, Role__c
                 FROM Solution_Finder_Permission__c
                 WHERE OwnerId =: userId
                 WITH SECURITY_ENFORCED
                 LIMIT 10000]) {
            assignments.add(new SolutionFinderAssignment(record));
        }
        return assignments;
    }
}