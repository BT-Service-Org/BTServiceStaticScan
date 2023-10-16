//Interface Class to trigger the Methodologies Slack App to send
//different messages in Slack

public interface MTH_SlackAppMessengerInterface {
    Id sendMethodDueMessages(List<Methods__c> methodsDue);
    Id sendMethodAssignedMessages(List<Methods__c> methodsAssigned);
    Id sendKickOffMessages(List<Project_Assignment__c> projectAssignments);
    Id sendSetupMessages(List<Project_Assignment__c> projectAssignments);
    Id sendWelcomeMessages(List<Project_Assignment__c> projectAssignments);
    Id sendSmartsheetMessages(List<Project_Assignment__c> projectAssignments);
    Id sendGenericMessages(List<MTH_MessagePayload> payloads);
}