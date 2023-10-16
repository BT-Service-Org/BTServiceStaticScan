global with sharing class slack_FeedbackNotification {
    private final static Pattern channelPattern = Pattern.compile('^[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}$');
    private final static String SUCCESS_MESSAGE = 'Messages sent successfully';
    private final static String ERROR_BAD_CHANNEL = 'ERROR: Channel could not be determined ';
    private static String externalUrl = null;

    @testVisible
    private static MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();
    @testVisible
    private static User testUser;

    @InvocableMethod(label='Send Article Feedback Notification')
    global static List<String> sendMessage(List<FeedbackMessage> feedbackMessages) {
        String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
        if (externalUrl == null) {
            externalUrl = getExternalUrl();
        }
        List<String> results = new List<String>();
        for (FeedbackMessage feedbackMessage : feedbackMessages) {
            String channelId = null;

            Matcher m = channelPattern.matcher(feedbackMessage.channel);
            if (m.matches()) {
                User user = null;
                if (Test.isRunningTest()) {
                    user = testUser;
                } else {
                    user = [SELECT Id, Name, FederationIdentifier, Slack_User_Id__c FROM User WHERE Id = :feedbackMessage.channel LIMIT 1];
                }
                System.debug(user);
                channelId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(user);
                System.debug(channelId);

                if (channelId == 'Email Mismatch') {
                    results.add(ERROR_BAD_CHANNEL + channelId);
                    continue;
                }
            }

            Article_Feedback__c feedbackObj = feedbackMessage.feedback;
            

            Slack.ViewReference viewRef = Slack.View.article_feedback_notification.get();
            viewRef.setParameter('messageLine1', feedbackMessage.messageLine1);
            viewRef.setParameter('messageLine2', feedbackMessage.messageLine2);
            viewRef.setParameter('articleTitle', feedbackMessage.articleTitle);
            viewRef.setParameter('articleLink', externalUrl + '/article/' + feedbackObj.Knowledge__c);
            viewRef.setParameter('feedback', feedbackObj.Feedback__c == null ? '' : feedbackObj.Feedback__c);
            viewRef.setParameter('feedbackLink', baseUrl + '/lightning/r/afl__afl_Article_Feedback__c/' + feedbackObj.Id + '/view');
            viewRef.setParameter('reviewComments', feedbackObj.Review_Comments__c);
            viewRef.setParameter('showReviewComments', feedbackMessage.showReviewerComments == null ? false : feedbackMessage.showReviewerComments);     
            viewRef.setParameter('showFeedbackButton', feedbackMessage.showReviewButton == null ? false : feedbackMessage.showReviewButton);
      
            slackApi.postMessage(viewRef, channelId);
            results.add(SUCCESS_MESSAGE);
        }

        System.debug(results);
        return results;
        
    }
 
    /*
    * Retrieves and stores the external url in a static String to avoid multiple SOQL calls.
    */
    public static String getExternalUrl() {
        if (Schema.sObjectType.Site.fields.Id.isAccessible() && Schema.sObjectType.SiteDetail.fields.SecureURL.isAccessible()) {
            String siteId = [SELECT Id FROM Site WHERE Name = 'Services_Central1' LIMIT 1].Id;
            String sitePrefix = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId].SecureUrl;

            if (sitePrefix != null) {
                return sitePrefix;
            } else {
                System.debug('Cannot determine external site prefix');
                return null;
            }
        } else {
            return null;
        }
    
    }

    global class FeedbackMessage {
        @InvocableVariable(label='User Id' required=true)
        global String channel;
        @InvocableVariable(label='Feedback Object' required=true)
        global Article_Feedback__c feedback;
        @InvocableVariable(label='Article Title' required=true)
        global String articleTitle;
        @InvocableVariable(label='Message Line 1' required=true)
        global String messageLine1;
        @InvocableVariable(label='Message Line 2' required=false)
        global String messageLine2;
        @InvocableVariable(label='Show Reviewer Comments' required=false)
        global Boolean showReviewerComments;
        @InvocableVariable(label='Show Review Button' required=false)
        global Boolean showReviewButton;
    }

}