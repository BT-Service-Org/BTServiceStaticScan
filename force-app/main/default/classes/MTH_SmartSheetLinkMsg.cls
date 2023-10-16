public with sharing class MTH_SmartSheetLinkMsg implements Queueable, Database.AllowsCallouts {

    @testVisible
    private static ContactDAI contactDA = new ContactDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

    public List<Project_Assignment__c> assignments;

    public MTH_SmartSheetLinkMsg(List<Project_Assignment__c> assignments) {
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
            if (String.valueOf(assignment?.Project_Role__c)?.contains('Project Manager')||String.valueOf(assignment?.Project_Role__c)?.contains('Engagement Manager')) {
                sendSmartsheetMessages(assignment, usersByContactIds);
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
            if (m.Message__c == 'Kick Off Message' || String.isBlank(m.Message__c)) {
                textConfig.put(m.Section__c, m.Text__c);
            }
        }
        return textConfig;
    }

    private void sendSmartsheetMessages(
        Project_Assignment__c assignment,
        Map<Id, User> usersByContactIds
    ) {
        
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        
        String projectLink = MTH_ProjectUtils.getProjectUrl(assignment.PSA_Project__r, settings);
	
        Slack.ViewReference view = Slack.view.mth_link_to_smartsheet_msg.get();
        User user = usersByContactIds.get(assignment.Resource__c);
      	view.setParameter('projectTitle', assignment.PSA_Project__r.Name);
        view.setParameter('projectLink', projectLink);
        view.setParameter('smartsheetLink', assignment.PSA_Project__r.SmartSheet_Link__c);
        view.setParameter('textConfig', getTextConfig());
        MTH_SlackMessageSender.sendMessageToUser(user,view);
    }
    
    public class NoSmartSheetLinkFoundException extends Exception {
    }
    
    public class UnrecognizedErrorWhileSendingMsgException extends Exception {
    }
}