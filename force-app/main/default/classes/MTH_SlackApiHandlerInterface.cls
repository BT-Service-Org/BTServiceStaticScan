public interface MTH_SlackApiHandlerInterface {
    Slack.User getUserByEmail(String email);
    String postMessage(Slack.ViewReference view, String channelId);
    String postMessage(String text, String channelId);
    String postPinnedMessage(Slack.ViewReference view, String channelId);
    void updateMessage(Slack.ViewReference view, String channelId, String ts);
    void postErrorOrConfirmationMessage(Slack.ViewReference view);
    void inviteUsersToChannelWithRetry(String channelId, String invitingUserId, String teamId, List<String> users);
    void inviteUsersToChannelWithRetry(String channelId, String teamId, List<String> users);
    Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate);
    Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate, String userId);
}