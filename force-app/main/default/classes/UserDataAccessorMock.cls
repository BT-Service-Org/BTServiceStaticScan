@isTest
public with sharing class UserDataAccessorMock implements UserDAI {
    public List<User> usersWSlackData = new List<User>();
    public List<User> updatedUsers = new List<User>();

    public List<User> getSlackUserInfoFromUserIds(Set<Id> userIds) {
        return usersWSlackData;
    }

    public List<User> getSlackUserInfoFromEmailIds(Set<String> emailIds) {
        usersWSlackData.add(new User(username = 'test@salesforce.com',Slack_User_Id__c='test1234'));
        return usersWSlackData;
    }

    public List<User> getSlackUserInfoFromContacts(Set<Id> contactIds) {
        return usersWSlackData;
    }

    public List<User> updateUsers(List<User> usersToUpdate) {
        updatedUsers.addAll(usersToUpdate);
        return updatedUsers;
    }
}