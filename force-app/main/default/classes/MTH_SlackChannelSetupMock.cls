@isTest
public with sharing class MTH_SlackChannelSetupMock implements MTH_SlackChannelSetupInterace {
    public String initChannel(
        PSA_Project__c project,
        String teamId,
        String userId,
        Boolean generateChannelNameSuffix
    ) {
        return 'channelid';
    }

    public void postProjectKTData(
        PSA_Project__c project,
        String targetChannelId,
        String spwLink,
        String accountChannelId,
        String teamId,
        String userId
    ) {
        return;
    }
}