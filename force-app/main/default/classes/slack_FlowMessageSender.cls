global with sharing class slack_FlowMessageSender {
    private final static Pattern channelPattern = Pattern.compile('^[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}$');
    private final static String SUCCESS_MESSAGE = 'Messages sent successfully';
    private final static String ERROR_BAD_CHANNEL = 'ERROR: Channel could not be determined ';

    @testVisible
    private static MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();
    @testVisible
    private static User testUser;

    @InvocableMethod(label='Send Simple Message')
    global static List<String> sendMessage(List<SlackMessage> slackMessages) {

        List<String> results = new List<String>();
        for (SlackMessage slackMessage : slackMessages) {
            Slack.ViewReference viewRef = Slack.View.simple_notification.get();
            viewRef.setParameter('messageText', slackMessage.messageText);

            List<String> sendResults = new List<String>();
            for (String channelId: slackMessage.channel.split(',')) {
                channelId = channelId.trim();
                if (channelId.length() == 0) {
                    continue;
                } 

                Matcher m = channelPattern.matcher(channelId);
                if (m.matches()) {
                    User user = null;
                    if (Test.isRunningTest()) {
                        user = testUser;
                    } else {
                        user = [SELECT Id, Name, FederationIdentifier, Slack_User_Id__c FROM User WHERE Id = :channelId LIMIT 1];
                    }
                    channelId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(user);


                    if (channelId == 'Email Mismatch') {
                        sendResults.add(ERROR_BAD_CHANNEL + channelId);
                        continue;
                    }
                } else {
                    channelId = slackMessage.channel;
                }

                slackApi.postMessage(viewRef, channelId);
                sendResults.add(SUCCESS_MESSAGE);
            }
            results.add(sendResults.toString());
        }

        System.debug(results);
        return results;
        
    }
    
    global class SlackMessage {
        @InvocableVariable(label='Channel (user id can also be specified)' required=true)
        global String channel;

        @InvocableVariable(label='Message to send' required=true)
        global String messageText;
    }

}