public with sharing class MTH_SlackMessageSender {
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();
    @testVisible
    private static MTH_SlackApiHandlerInterface slackApiHandler = new MTH_SlackApiHandler();

    private static List<User> getUsersFromUserMap(Map<Id, User> usersById, Set<Id> userIds) {
        List<User> usersToReturn = new List<User>();
        for (Id uId : userIds) {
            usersToReturn.add(usersById.get(uId));
        }
        return usersToReturn;
    }

    public static void sendMessageToUser(User u, Slack.ViewReference view) {
        if(u != null){
            String slackUserId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
            slackApiHandler.postMessage(view, slackUserId);
        }else{
            System.debug('User record is null');
        }
    }

    public static void sendMessageToUsers(List<User> users, Slack.ViewReference view) {
        for (User u : users) {
            sendMessageToUser(u, view);
        }
    }

    //Note: This method uses SOQL and DML and therefore should not be
    //  called within a loop
    public static void sendMessageToUsers(Set<Id> userIds, Slack.ViewReference view) {
        List<User> users = userDA.getSlackUserInfoFromUserIds(userIds);
        sendMessageToUsers(users, view);
        userDA.updateUsers(users);
    }

    //Note: This method uses SOQL and DML and therefore should not be
    //  called within a loop
    public static void sendMultipleMessagesToUserIds(
        Map<Slack.ViewReference, List<Id>> userIdsByMessageToSend
    ) {
        Set<Id> allUserIds = new Set<Id>();
        for (Slack.ViewReference vr : userIdsByMessageToSend.keySet()) {
            allUserIds.addAll(userIdsByMessageToSend.get(vr));
        }

        Map<Id, User> usersById = new Map<Id, User>(userDA.getSlackUserInfoFromUserIds(allUserIds));

        for (Slack.ViewReference vr : userIdsByMessageToSend.keySet()) {
            List<User> usersToSendMessage = getUsersFromUserMap(
                usersById,
                new Set<Id>(userIdsByMessageToSend.get(vr))
            );
            sendMessageToUsers(usersToSendMessage, vr);
        }
        //user objects were updated by getting slack user ids
        userDA.updateUsers(usersById.values());
    }

    public static String formatDateStringForMessages(Date dueDate) {
        if (dueDate == null) {
            return '';
        }
        return ' by ' + dueDate.month() + '/' + dueDate.day() + '/' + dueDate.year();
    }

    public static void sendErrorMessage(String slackId, String errorCause) {
        Slack.ViewReference viewReference = Slack.View.mth_msg_error.get();
        if (String.isNotBlank(errorCause)) {
            viewReference.setParameter('errorCause', '\nError: ' + errorCause);
        } 
        viewReference.setParameter('slackId', getSlackIdString(slackId));
        slackApiHandler.postErrorOrConfirmationMessage(viewReference);
    }

    public static void sendConfirmationMessage(String slackId) {
        Slack.ViewReference viewReference = Slack.View.mth_admin_modal_confirm.get();
        viewReference.setParameter('slackId', getSlackIdString(slackId));
        slackApiHandler.postErrorOrConfirmationMessage(viewReference);
    }

    private static String getSlackIdString(String slackId) {
        if (slackId.startsWith('C')) {
            return ' to <#' + slackId + '> ';
        } else if (String.isBlank(slackId)) {
            return ' ';
        } else {
            return ' to <@' + slackId + '> ';
        }
    }
}