public with sharing class MTH_SlackChannelSetup implements MTH_SlackChannelSetupInterace {
    private Slack.App app;

    @testVisible
    private static MTH_SlackApiHandlerInterface slackApiHander = new MTH_SlackApiHandler();

    public MTH_SlackChannelSetup() {
        this.app = Slack.App.Methodologies.get();
    }

    public String initChannel(PSA_Project__c project, String teamId, String userId, Boolean generateChannelNameSuffix) {
        String channelId;
        String channelName = getProjectChannelName(project, generateChannelNameSuffix);

        // First try creating a channel on behalf of the user. Create with bot as a fallback
        try {
            channelId = createChannelAsUser(channelName, userId);

            if (channelId == null) {
                channelId = createChannelAsBot(channelName);
                inviteUserAsChannelManager(userId, channelId, teamId);
            }
        } catch (MTH_SlackApiErrors.ChannelCreateException error) {
            throw error;
        }
        return channelId;
    }

    private void inviteUserAsChannelManager(String userId, String channelId, String teamId) {
        if (channelId == null) {
            return;
        }
        List<String> users = new List<String>{ userId };
        slackApiHander.inviteUsersToChannelWithRetry(channelId, teamId, users);
        /* 
        TODO: set userId as Channel Manager - how to?
        Probably need to use admin API and assign Channel Manager role with https://api.slack.com/methods/admin.roles.addAssignments.
        But Apex Slack SDK does not support it so probably need to define an External Service and use that:
        https://help.salesforce.com/s/articleView?id=sf.external_services_register.htm&type=5
        https://help.salesforce.com/s/articleView?id=sf.external_services_apex_registrations.htm&type=5
        https://help.salesforce.com/s/articleView?id=sf.external_services_apex_invoking.htm&type=5
        
        BUT - Admin scope will not be allowed - so not an option for now.
        */
    }

    public void postProjectKTData(
        PSA_Project__c project,
        String targetChannelId,
        String spwLink,
        String accountChannelId,
        String teamId,
        String userId
    ) {
        try {
            System.enqueueJob(
                new MTH_SlackProjectKTDataHandler(
                    project,
                    targetChannelId,
                    spwLink,
                    accountChannelId,
                    teamId,
                    userId
                )
            );
        } catch (Exception e) {
            System.debug('*** Exception happened when posting project KT data ' + e.getMessage());
        }
    }

    private String createChannelAsBot(String name) {
        Slack.ConversationsCreateResponse res = slackApiHander.createChannel(name, false);
        if (res.getError() == null) {
            return res.getChannel().getId();
        }
        if (res.getError() == 'name_taken') {
            throw new MTH_SlackApiErrors.ChannelCreateException(res.getError(), name);
        }
        System.debug('** SLACK API ERROR on creating channel: ' + res.getError());
        return null;
    }

    private String createChannelAsUser(String name, String userId) {
        Slack.ConversationsCreateResponse res = slackApiHander.createChannel(name, false, userId);
        if (res.getError() == null) {
            return res.getChannel().getId();
        }
        if (res.getError() == 'name_taken') {
            throw new MTH_SlackApiErrors.ChannelCreateException(res.getError(), name);
        }
        System.debug('** SLACK API ERROR on creating channel: ' + res.getError());
        return null;
    }

    private static String getRandomSuffix() {
        final String chars = '0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        Integer TARGET_LENGTH = 7;
        while (randStr.length() < TARGET_LENGTH) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    private static String getCoreName(PSA_Project__c project, Integer maxLength) {
        String coreName = '';
        if (!String.isBlank(project.Opportunity__r.Name)) {
            coreName = project.Opportunity__r.Name;
        } else {
            coreName = project.Name;
        }
        String invalidCharsRegex = '[^a-z\\d\\s:]';
        String whitespacesRegex = '[ \t]+';
        return coreName.trim()
            .toLowerCase()
            .replaceAll(invalidCharsRegex, '')
            .replaceAll(whitespacesRegex, '-')
            .left(maxLength);
    }

    private static String getProjectChannelName(PSA_Project__c project, Boolean withSuffix) {
        final Integer SLACK_MAX_CHANNEL_NAME_LENGTH = 80;
        String prefix = 'proj-proserv-';
        String suffix = '';
        if (withSuffix) {
            suffix = '-' + getRandomSuffix();
        }
        Integer maxCoreLength = SLACK_MAX_CHANNEL_NAME_LENGTH - prefix.length() - suffix.length();
        String name = getCoreName(project, maxCoreLength);
        return prefix + name + suffix;
    }
}