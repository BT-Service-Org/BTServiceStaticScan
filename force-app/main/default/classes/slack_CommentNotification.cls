global with sharing class slack_CommentNotification {
    public slack_CommentNotification() {

    }
    private final static Pattern channelPattern = Pattern.compile('^[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}$');
    private final static String SUCCESS_MESSAGE = 'Messages sent successfully';
    private final static String ERROR_BAD_CHANNEL = 'ERROR: Channel could not be determined ';
    private static String externalUrl = null;

    @testVisible
    private static MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();
    @testVisible
    private static User testUser;

    @InvocableMethod(label='Send Cooment Notification')
    global static List<String> sendMessage(List<Id> feedbackIDs) {
        String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
        if (externalUrl == null) {
            externalUrl = slack_FeedbackNotification.getExternalUrl();
        }
        List<String> results = new List<String>();
       return null;
    }
 
}