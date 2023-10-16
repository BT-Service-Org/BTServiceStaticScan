public interface UserDAI {
    List<User> getSlackUserInfoFromUserIds(Set<Id> userIds);
    List<User> updateUsers(List<User> usersToUpdate);
    List<User> getSlackUserInfoFromContacts(Set<Id> contactIds);
    List<User> getSlackUserInfoFromEmailIds(Set<String> emailIds);
}