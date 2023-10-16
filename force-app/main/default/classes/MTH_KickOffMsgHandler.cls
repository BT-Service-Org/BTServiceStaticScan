public with sharing class MTH_KickOffMsgHandler implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static ContactDAI contactDA = new ContactDataAccessor();

    public List<Project_Assignment__c> assignments;

    public MTH_KickOffMsgHandler(List<Project_Assignment__c> assignments) {
        this.assignments = assignments;
    }

    public void execute(QueueableContext context) {
        Map<Id, User> contactsToUser = getContactToUserMap(assignments);
        Map<Id, PSA_Project__c> projectsById = getProjectsById(assignments);

        for (Project_Assignment__c assignment : this.assignments) {
            buildAndSend(assignment, contactsToUser, projectsById);
        }
    }

    private static Map<String, String> getTextConfig() {
        List<Methodologies_Slack_App_Message_Text__mdt> configuredMessageTexts = Methodologies_Slack_App_Message_Text__mdt.getAll()
            .values();

        Map<String, String> textConfig = new Map<String, String>();
        for (Methodologies_Slack_App_Message_Text__mdt m : configuredMessageTexts) {
            if (m.Message__c == 'Kick Off Message' || String.isBlank(m.Message__c)) {
                textConfig.put(m.Section__c, m.Text__c);
            }
        }
        return textConfig;
    }

    public static Slack.ViewReference buildAndSend(
        Project_Assignment__c assignment,
        Map<Id, User> contactsToUsers,
        Map<Id, PSA_Project__c> projectsById
    ) {
        User user = contactsToUsers.get(assignment.Resource__c);
        Map<String, String> projectMap = getProjectAndReturnMap(assignment, projectsById);
        Map<String, String> userMap = getUserInfoAndReturnMap(user);

        Slack.ViewReference viewReference = Slack.View.mth_msg_kick_off.get();
        viewReference.setParameter('user', userMap);
        viewReference.setParameter('project', projectMap);

        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        viewReference.setParameter('org62Url', settings.Org_62_Url__c);
        viewReference.setParameter('textConfig', getTextConfig());
        MTH_SlackMessageSender.sendMessageToUser(user, viewReference);

        return viewReference;
    }

    private static Map<Id, PSA_Project__c> getProjectsById(
        List<Project_Assignment__c> assignments
    ) {
        Set<Id> projectIds = new Set<Id>();
        for (Project_Assignment__c assignment : assignments) {
            projectIds.add(assignment.PSA_Project__c);
        }
        return new Map<Id, PSA_Project__c>(projectDA.getPSAProjectByProjectId(projectIds));
    }

    private static Map<String, String> getProjectAndReturnMap(
        Project_Assignment__c assignment,
        Map<Id, PSA_Project__c> projectsById
    ) {
        PSA_Project__c project = projectsById.get(assignment.PSA_Project__c);
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Name', assignment.PSA_Project__r.Name);
        projectMap.put('Id', project.Id);
        projectMap.put('End_Date__c', String.valueOf(assignment.End_Date__c));
        projectMap.put('Org62_Id__c', String.valueOf(project.Org62_Id__c));
        projectMap.put('Org62_Opportunity_Id__c', String.valueOf(project.Org62_Opportunity_Id__c));
        
        if (String.isNotBlank(project.SmartSheet_Link__c)){
            projectMap.put('Smartsheet', '\n\n:computer: <' + String.valueOf(project.SmartSheet_Link__c) + '|Project Smartsheet>');
        } 

        if (String.isNotBlank(assignment.Project_Role__c)){
            projectMap.put('Project_Role__c', ' the role of *' + assignment.Project_Role__c + '* on');
        } else {
            projectMap.put('Project_Role__c', '');
        }

        return projectMap;
    }

    private static Map<String, String> getUserInfoAndReturnMap(User user) {
        Map<String, String> userMap = new Map<String, String>();
        userMap.put('Name', user.Name);
        userMap.put('SlackId', user.Slack_User_Id__c);
        userMap.put('Id', user.Id);

        return userMap;
    }

    private static Map<Id, User> getContactToUserMap(List<Project_Assignment__c> assignmentList) {
        Set<Id> contactIds = new Set<Id>();
        for (Project_Assignment__c a : assignmentList) {
            contactIds.add(a.Resource__c);
        }

        List<Contact> contacts = contactDA.getContactUserRecordsByContactIds(contactIds);
        Map<Id, Id> contactToUserIdMap = new Map<Id, Id>();
        for (Contact c : contacts) {
            contactToUserIdMap.put(c.Id, c.User_Record__c);
        }

        Map<Id, User> usersFromContacts = new Map<Id, User>(
            userDA.getSlackUserInfoFromUserIds(new Set<Id>(contactToUserIdMap.values()))
        );
        Map<Id, User> contactToUser = new Map<Id, User>();

        for (Id key : contactToUserIdMap.keySet()) {
            contactToUser.put(key, usersFromContacts.get(contactToUserIdMap.get(key)));
        }

        return contactToUser;
    }
}