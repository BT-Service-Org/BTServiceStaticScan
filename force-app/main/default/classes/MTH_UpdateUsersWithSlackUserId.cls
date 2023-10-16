//we frequently need to update users with slack ids after getting them
// from slack. That is in a future context, and the user trigger
// has a future, which causes it to fail if there
// is not separation as within a queueable.

public with sharing class MTH_UpdateUsersWithSlackUserId implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static UserDAI userDa = new UserDataAccessor();

    private Set<Id> userIds;
    public MTH_UpdateUsersWithSlackUserId(Set<Id> userIdsToUpdate) {
        userIds = userIdsToUpdate;
    }
    public void execute(QueueableContext context) {
        List<User> users = userDa.getSlackUserInfoFromUserIds(userIds);
        List<User> updatedUsers = new List<User>();
        for (User u : users) {
            if (String.isBlank(u.Slack_User_Id__c)) {
                MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
                updatedUsers.add(u);
            }
        }
        userDa.updateUsers(updatedUsers);
    }
}