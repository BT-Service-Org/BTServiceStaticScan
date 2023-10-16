public with sharing class MTH_SlackUserIdHandler {
    @testVisible
    private static MTH_SlackApiHandlerInterface slackApiHandler = new MTH_SlackApiHandler();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    public static Boolean didCallSlackApi { get; private set; }

    //this does SOQL and therefore should not be called in a loop
    public static String getSlackIdFromContextOrRunningUserId(Slack.RequestContext context) {
        if (String.isNotBlank(context?.getUserId())) {
            return context.getUserId();
        }
        //the below shouldn't be necessary, but for some reason the user id isn't always in the request context
        System.debug('getting user slack id from context | had to fallback to cache');
        List<User> users = userDA.getSlackUserInfoFromUserIds(new Set<Id>{ UserInfo.getUserId() });
        return getSlackUserIdFromSFUser(users[0]);
    }

    public static String getSlackUserIdFromSFUser(User u) {
        if (didCallSlackApi == null) {
            didCallSlackApi = false;
        }
        if (!String.isBlank(u.Slack_User_Id__c)) {
            return u.Slack_User_Id__c;
        }
        didCallSlackApi = true;
        try {
            Slack.User slackUser = slackApiHandler.getUserByEmail(u.FederationIdentifier);
            u.Slack_User_Id__c = slackUser.getId();
        } catch (MTH_SlackApiErrors.UserLookupByEmailException e) {
            u.Slack_User_Id__c = 'Email Mismatch';
        }
        return u.Slack_User_Id__c;
    }
}