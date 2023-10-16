public with sharing class MTH_WelcomeMsgHandler implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static ContactDAI contactDA = new ContactDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();

    public List<Project_Assignment__c> assignments;

    public MTH_WelcomeMsgHandler(List<Project_Assignment__c> assignments) {
        this.assignments = assignments;
    }

    public void execute(QueueableContext context) {
        List<Contact> contacts = contactDA.getContactUserRecordsByContactIds(
            getContactIds(assignments)
        );
        Map<Id, User> usersByUserId = new Map<Id, User>(
            userDA.getSlackUserInfoFromUserIds(getUserIds(contacts))
        );
        Map<Id, User> usersByContactIds = mapUsersToContactIds(contacts, usersByUserId);

        for (Project_Assignment__c assignment : assignments) {
            if (!String.valueOf(assignment?.Project_Role__c)?.contains('Project Manager')) {
                sendWelcomeMessages(assignment, usersByContactIds);
            }
        }
    }

    private Set<Id> getContactIds(List<Project_Assignment__c> projectAssignments) {
        Set<Id> contactIds = new Set<Id>();
        for (Project_Assignment__c pa : projectAssignments) {
            contactIds.add(pa.Resource__c);
        }
        return contactIds;
    }
    private Set<Id> getUserIds(List<Contact> contacts) {
        Set<Id> userIds = new Set<Id>();
        for (Contact c : contacts) {
            userIds.add(c.User_Record__c);
        }
        return userIds;
    }
    private Map<Id, User> mapUsersToContactIds(
        List<Contact> contacts,
        Map<Id, User> usersByUserIds
    ) {
        Map<Id, User> usersByContactIds = new Map<Id, User>();
        for (Contact c : contacts) {
            usersByContactIds.put(c.Id, usersByUserIds.get(c.User_Record__c));
        }
        return usersByContactIds;
    }

    private Map<String, String> getTextConfig() {
        List<Methodologies_Slack_App_Message_Text__mdt> configuredMessageTexts = Methodologies_Slack_App_Message_Text__mdt.getAll()
            .values();

        Map<String, String> textConfig = new Map<String, String>();
        for (Methodologies_Slack_App_Message_Text__mdt m : configuredMessageTexts) {
            if (m.Message__c == 'Welcome Message' || String.isBlank(m.Message__c)) {
                textConfig.put(m.Section__c, m.Text__c);
            }
        }
        return textConfig;
    }

    private String getKnowledgeCenterLink(Id projectId){
        PSA_Project__c[] projects = psaProjectDA.getPSAProjectAndOpportunityByProjectId(new Set<Id>{projectId});
        PSA_Project__c project = projects[0];
        String knowledgeLink ='\n• <https://sfservices.my.site.com/ServicesCentral/s/global-search/%40uri#sort=relevancy';
        if (String.isNotBlank(project.Opportunity__r.Targeted_Clouds__c)) {
            String targetedClouds = (project.Opportunity__r.Targeted_Clouds__c).replace(';', ',');
            knowledgeLink = '\n• <https://sfservices.my.site.com/ServicesCentral/s/global-search/%40uri#sort=relevancy&f:@gkcparentproductnames=[' + targetedClouds + ']';
        }
        return knowledgeLink;
    }

    private void sendWelcomeMessages(
        Project_Assignment__c assignment,
        Map<Id, User> usersByContactIds
    ) {

        Slack.ViewReference view = Slack.view.mth_msg_welcome.get();
        view.setParameter('projectName', assignment.PSA_Project__r.Name);
        view.setParameter('projectId', assignment.PSA_Project__c);
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        view.setParameter('org62Url', settings.Org_62_Url__c);
        view.setParameter('org62Id', assignment.PSA_Project__r.Org62_Id__c);
        view.setParameter('methodologiesChannelId', settings.General_Information_Slack_Channel_Id__c);
        view.setParameter('textConfig', getTextConfig());
        view.setParameter('knowledgeLink', getKnowledgeCenterLink(assignment.PSA_Project__c));
        MTH_SlackMessageSender.sendMessageToUser(
            usersByContactIds.get(assignment.Resource__c),
            view
        );
    }
}