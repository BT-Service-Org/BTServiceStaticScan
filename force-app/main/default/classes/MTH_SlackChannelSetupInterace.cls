public interface MTH_SlackChannelSetupInterace {
    String initChannel(
        PSA_Project__c project,
        String teamId,
        String userId,
        Boolean generateChannelNameSuffix
    );
    void postProjectKTData(
        PSA_Project__c project,
        String targetChannelId,
        String spwLink,
        String accountChannelId,
        String teamId,
        String userId
    );
}