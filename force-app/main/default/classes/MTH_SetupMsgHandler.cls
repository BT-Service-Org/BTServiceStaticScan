public with sharing class MTH_SetupMsgHandler implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static ContactDAI contactDA = new ContactDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    public List<Project_Assignment__c> assignments;

    public MTH_SetupMsgHandler(List<Project_Assignment__c> assignments) {
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
            sendSetupMessages(assignment, usersByContactIds);
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

    private Map<String, String> getProjectMap(PSA_Project__c project) {
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Name', project.Name);
        projectMap.put('Org62Id', project.Org62_Id__c);
        projectMap.put('Id', project.Id);
        return projectMap;
    }

    private Map<String, String> getProjectAssignmentMap(Project_Assignment__c assignment, User user) {
        Map<String, String> projectAssignmentMap = new Map<String, String>();
        projectAssignmentMap.put('StartDate', (assignment.Start_Date__c)?.format());
        projectAssignmentMap.put('SlackId', user.Slack_User_Id__c);
        projectAssignmentMap.put('Role', assignment.Project_Role__c);
        return projectAssignmentMap;
    }

    private void sendSetupMessages(
        Project_Assignment__c assignment,
        Map<Id, User> usersByContactIds
    ) {

        Slack.ViewReference view = Slack.view.mth_msg_setup.get();
        User user = usersByContactIds.get(assignment.Resource__c);
        view.setParameter('assignment', getProjectAssignmentMap(assignment, user));
        view.setParameter('project', getProjectMap(assignment.PSA_Project__r));
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        view.setParameter('methodologiesChannelId', settings.General_Information_Slack_Channel_Id__c);
        view.setParameter('methodologiesDocumentation', 'https://sfservices.my.site.com/ServicesCentral/s/methodology');
        view.setParameter('org62Url', settings.Org_62_Url__c);
        view.setParameter('textConfig', getTextConfig());
        MTH_SlackMessageSender.sendMessageToUser(
            user,
            view
        );
    }
}