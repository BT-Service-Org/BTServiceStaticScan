@isTest
public with sharing class MTH_SlackApiHandlerMock implements MTH_SlackApiHandlerInterface {
    public List<String> getUserByEmailCalls = new List<String>();
    public Slack.User getUserByEmail(String email) {
        getUserByEmailCalls.add(email);
        Slack.User slackUser = new Slack.User();
        slackUser.setId(String.valueOf(getUserByEmailCalls.size()));
        return slackUser;
    }

    public List<String> channelsSentMessage = new List<String>();
    public String postMessage(Slack.ViewReference view, String channelId) {
        channelsSentMessage.add(channelId);
        return 'msg-ts';
    }

    public String postMessage(String text, String channelId) {
        channelsSentMessage.add(channelId);
        return 'msg-ts';
    }

    public List<String> channelsPinnedSentMessage = new List<String>();
    public String postPinnedMessageExpectedResult = 'msg-ts';
    public String postPinnedMessage(Slack.ViewReference view, String channelId) {
        channelsPinnedSentMessage.add(channelId);
        return postPinnedMessageExpectedResult;
    }

    public List<Slack.ViewReference> messageViewsSent = new List<Slack.ViewReference>();
    public void postErrorOrConfirmationMessage(Slack.ViewReference view) {
        messageViewsSent.add(view);
        return;
    }

    public List<String> updateMessageChannelIdTsCalls = new List<String>();
    public void updateMessage(Slack.ViewReference view, String channelId, String ts) {
        updateMessageChannelIdTsCalls.add(channelId + '|' + ts);
        return;
    }

    public List<String> channelInviteCalls = new List<String>();
    public void inviteUsersToChannelWithRetry(String channelId, String invitingUserId, String teamId, List<String> users){
        channelInviteCalls.add(channelId+'|'+String.join(users,','));
        return;
    }

    public void inviteUsersToChannelWithRetry(String channelId, String teamId, List<String> users){
        channelInviteCalls.add(channelId+'|'+String.join(users,','));
        return;
    }

    public List<String> channelCreateCalls = new List<String>();
    public Slack.ConversationsCreateResponse channelCreateExpectedResponse = new Slack.ConversationsCreateResponse();
    public Slack.ConversationsCreateResponse channelCreateAsUserExpectedResponse = new Slack.ConversationsCreateResponse();
    public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate){
        channelCreateCalls.add(name+'|'+isPrivate);
        return channelCreateExpectedResponse;
    }

    public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate, String userId){
        channelCreateCalls.add(name+'|'+isPrivate);
        return channelCreateAsUserExpectedResponse;
    }
}