public with sharing class UserDataAccessor implements UserDAI {
    public List<User> getSlackUserInfoFromUserIds(Set<Id> userIds) {
        return [
            SELECT Id, Name, FederationIdentifier, Slack_User_Id__c
            FROM User
            WHERE Id IN :userIds
            WITH SECURITY_ENFORCED
        ];
    }

    public List<User> getSlackUserInfoFromEmailIds(Set<String> emailIds) {
        return [
            SELECT Id, Name, FederationIdentifier, Slack_User_Id__c, Email
            FROM User
            WHERE Email IN :emailIds AND Slack_User_Id__c <> null
            WITH SECURITY_ENFORCED
        ];
    }

    public List<User> getSlackUserInfoFromContacts(Set<Id> contactIds) {
        return [
            SELECT Id, Name, FederationIdentifier, Slack_User_Id__c
            FROM User u
            WHERE u.Id IN (SELECT User_Record__c FROM Contact WHERE Id IN :contactIds)
            WITH SECURITY_ENFORCED
        ];
    }

    public List<User> updateUsers(List<User> usersToUpdate) {
        if (usersToUpdate?.isEmpty() == false) {
            update usersToUpdate;
        }
        return usersToUpdate;
    }
}