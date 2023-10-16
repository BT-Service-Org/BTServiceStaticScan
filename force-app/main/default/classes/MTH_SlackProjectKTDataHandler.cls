public with sharing class MTH_SlackProjectKTDataHandler implements Queueable, Database.AllowsCallouts {
    private PSA_Project__c project;
    private String targetChannelId;
    private String teamId;
    private String spwLink;
    private String accountChannelId;
    private String userId;
    @testVisible
    private static ProjectAssignmentDAI assignmentDa = new ProjectAssignmentDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();
    @testVisible
    private static MTH_SlackApiHandlerInterface slackApiHandler = new MTH_SlackApiHandler();

    public MTH_SlackProjectKTDataHandler(
        PSA_Project__c project,
        String targetChannelId,
        String spwLink,
        String accountChannelId,
        String teamId,
        String userId
    ) {
        this.project = project;
        this.targetChannelId = targetChannelId;
        this.spwLink = spwLink;
        this.accountChannelId = accountChannelId;
        this.teamId = teamId;
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        List<String> users = getTargetChannelMembers(this.project.Id);
        slackApiHandler.inviteUsersToChannelWithRetry(this.targetChannelId, this.userId, this.teamId, users);
        Boolean isResultOk = buildAndSend(
            this.project,
            this.targetChannelId,
            this.teamId,
            this.spwLink,
            this.accountChannelId,
            true
        );

        if (!isResultOk) {
            // 2nd attempt - if failed to post to a channel, use a fallback and post as a DM
            notifyUserOnFailure(this.userId, this.targetChannelId);
            buildAndSend(
                this.project,
                this.userId,
                this.teamId,
                this.spwLink,
                this.accountChannelId,
                false
            );
        }
    }

    private List<String> getTargetChannelMembers(String projectId) {
        // Add bot
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        List<String> users = new List<String>{ settings.Bot_User_Id__c };

        // Add users from the project assignment
        List<Project_Assignment__c> assignments = assignmentDa.getProjectAssignmentsByProjectId(
            new Set<Id>{ projectId }
        );
        List<String> userIds = getSlackUserIdsFromAssignment(assignments);
        users.addAll(userIds);
        return users;
    }

    private List<String> getSlackUserIdsFromAssignment(List<Project_Assignment__c> assignments) {
        List<String> slackUserIds = new List<String>();
        Set<Id> userIds = new Set<Id>();
        for (Project_Assignment__c a : assignments) {
            userIds.add(a.Resource__r.User_Record__c);
        }
        List<User> slackUsers = userDA.getSlackUserInfoFromUserIds(userIds);
        for (User u : slackUsers) {
            String slackUserId = MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
            if (slackUserId != 'Email Mismatch') {
                slackUserIds.add(slackUserId);
            }
        }
        return slackUserIds;
    }

    public static Boolean buildAndSend(
        PSA_Project__c project,
        String targetChannelId,
        String teamId,
        String spwLink,
        String accountChannelId,
        Boolean shouldPinMessage
    ) {
        Slack.ViewReference view = Slack.View.mth_msg_project_info.get();
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        view.setParameter('project', getProjectDataMap(project, spwLink, accountChannelId, settings));
        view.setParameter('org62Url', settings.Org_62_Url__c);
        
        String msgTs;
        if (shouldPinMessage){
            msgTs = slackApiHandler.postPinnedMessage(view, targetChannelId);
        } else{
            msgTs = slackApiHandler.postMessage(view, targetChannelId);
        }
        
        return msgTs != null;
    }

    private static Map<String, String> getProjectDataMap(
        PSA_Project__c project,
        String spwLink,
        String accountChannelId,
        Methodologies_Slack_App_Settings__c settings
    ) {
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Name', project.Name);
        projectMap.put('url', MTH_ProjectUtils.getProjectUrl(project, settings));
        projectMap.put('Id', project.Id);
        projectMap.put('Start_Date__c', String.valueOf(project.Start_Date__c));
        projectMap.put('End_Date__c', String.valueOf(project.End_Date__c));
        projectMap.put('Billing_Type__c', project.Billing_Type__c);
        projectMap.put('Org62_Id__c', project.Org62_Id__c);
        projectMap.put('Org62_Opportunity_Id__c', project.Org62_Opportunity_Id__c);
        projectMap.put('Account_Channel_Id__c', accountChannelId);
        projectMap.put('SPW_Link__c', spwLink);
        projectMap.put('Org62_SOW_Link__c', project.Org62_SOW_Link__c);

        return projectMap;
    }

    private static void notifyUserOnFailure(String userId, String channelId) {
        String text = ':warning: The bot failed to post the data in <#' +
        channelId +
        '>.\nWe are sending it as a DM instead, please forward it to the right channel!';
        slackApiHandler.postMessage(text, userId);
    }
}