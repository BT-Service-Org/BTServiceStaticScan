public with sharing class MTH_SlackApiHandler implements MTH_SlackApiHandlerInterface {
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    private Slack.BotClient getBotClient() {
        String teamId = Methodologies_Slack_App_Settings__c.getInstance().Team_Id__c;
        Slack.App app = Slack.App.Methodologies.get();
        return app.getBotClientForTeam(teamId);
    }

    private Slack.UserClient getUserClient(String userId, String teamId) {
        Slack.App app = Slack.App.Methodologies.get();
        return app.getUserClientForTeam(teamId, userId);
    }

    public Slack.User getUserByEmail(String email) {
        Slack.UsersLookupByEmailRequest req = new Slack.UsersLookupByEmailRequest.Builder()
            .email(email)
            .build();
        Slack.UsersLookupByEmailResponse res = getBotClient().usersLookupByEmail(req);

        if (!res.isOk()) {
            throw new MTH_SlackApiErrors.UserLookupByEmailException(res.getError());
        }
        return res.getUser();
    }

    public String postMessage(Slack.ViewReference view, String channelId) {
        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.Builder()
            .channel(channelId)
            .viewReference(view)
            .build();
        Slack.ChatPostMessageResponse res = getBotClient().chatPostMessage(req);
        if (res.isOk()){
            return res.getMessage().getTs();
        }
        return null;
    }

    public String postMessage(String text, String channelId) {
        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.Builder()
            .channel(channelId)
            .text(text)
            .build();
        Slack.ChatPostMessageResponse res = getBotClient().chatPostMessage(req);
        if (res.isOk()){
            return res.getMessage().getTs();
        }
        return null;
    }

    public String postPinnedMessage(Slack.ViewReference view, String channelId) {
        String messageTs = this.postMessage(view, channelId);
        if (messageTs == null){
            return null;
        }
        Slack.PinsAddRequest.Builder pinReq = new Slack.PinsAddRequest.Builder();
        pinReq.channel(channelId);
        pinReq.timestamp(messageTs);
        getBotClient().pinsAdd(pinReq.build());
        return messageTs;
    }

    public void postErrorOrConfirmationMessage(Slack.ViewReference view) {
        List<User> users = userDA.getSlackUserInfoFromUserIds(new Set<Id>{ UserInfo.getUserId() });
        String slackUserId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(users[0]);
        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.Builder()
            .channel(slackUserId)
            .viewReference(view)
            .build();
        Slack.ChatPostMessageResponse res = getBotClient().chatPostMessage(req);
    }

    public void updateMessage(Slack.ViewReference view, String channelId, String ts) {
        Slack.ChatUpdateRequest req = new Slack.ChatUpdateRequest.Builder()
            .channel(channelId)
            .ts(ts)
            .viewReference(view)
            .build();
        Slack.ChatUpdateResponse res = getBotClient().chatUpdate(req);

        if (!res.isOk()) {
            throw new MTH_SlackApiErrors.ChatUpdateException(res.getError());
        }
    }

    public void inviteUsersToChannelWithRetry(
        String channelId,
        String invitingUserId,
        String teamId,
        List<String> users
    ) {
        inviteUsersToChannelWithRetry(channelId, invitingUserId, teamId, users, false);
    }

    public void inviteUsersToChannelWithRetry(
        String channelId,
        String teamId,
        List<String> users
    ) {
        inviteUsersToChannelWithRetry(channelId, null, teamId, users, false);
    }

    private void inviteUsersToChannelWithRetry(
        String channelId,
        String invitingUserId,
        String teamId,
        List<String> users,
        Boolean isRetry
    ) {
        try {
            Slack.ConversationsInviteRequest.Builder invReqBuilder = Slack.ConversationsInviteRequest.builder();
            invReqBuilder.channel(channelId);
            // We remove self from the user list, otherwise we'll get cannot_invite_self error
            users.remove(users.indexOf(invitingUserId));
            invReqBuilder.users(users);

            Slack.ConversationsInviteResponse resp;
            if (invitingUserId != null){
                Slack.UserClient client = getUserClient(invitingUserId, teamId);
                resp = client.conversationsInvite(
                    invReqBuilder.build()
                );
            }
            else {
                Slack.BotClient client = getBotClient();
                resp = client.conversationsInvite(invReqBuilder.build());
            }
            
            if (resp.isOk() || isRetry) {
                return;
            }
            // When some users fail, the whole bulk operation fails. Repeat the attempt one-by-one
            for (String u : users) {
                System.debug('*** Retrying user invite for ' + u + ' to channel ' + channelId);
                List<String> userToInvite = new List<String>{ u };
                inviteUsersToChannelWithRetry(
                    channelId,
                    invitingUserId,
                    teamId,
                    userToInvite,
                    true
                );
            }
        } catch (Exception e) {
            System.debug('*** Exception when inviting bot to the channel *** ' + e.getMessage());
        }
    }

    public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate, String userId){
        String teamId = Methodologies_Slack_App_Settings__c.getInstance().Team_Id__c;
        try {
            Slack.UserClient client = getUserClient(userId, teamId);
            return client.conversationsCreate(buildConversationRequest(name, isPrivate, teamId));
        } catch (Exception e){
            System.debug('*** Exception when getting user client *** ' + e.getMessage());
            return null;
        }
    }

    public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate){
        String teamId = Methodologies_Slack_App_Settings__c.getInstance().Team_Id__c;
        Slack.BotClient client = getBotClient();
        return client.conversationsCreate(buildConversationRequest(name, isPrivate, teamId));
    }

    private Slack.ConversationsCreateRequest buildConversationRequest(String name, Boolean isPrivate, String teamId) {
        Slack.ConversationsCreateRequest.Builder reqBuilder = Slack.ConversationsCreateRequest.builder();
        reqBuilder.isPrivate(isPrivate);
        reqBuilder.name(name);
        reqBuilder.teamId(teamId);
        return reqBuilder.build();
    }
}