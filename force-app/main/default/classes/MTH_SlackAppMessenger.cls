//Interface Class to trigger the Methodologies Slack App to send
//different messages in Slack

//For Testing: Since most of these methods fire off asynchronous events
// and do a lot of things with the Slack API, it might be helpful
// for classes which call this class to mock it in their tests, using
// the related classes MTH_SlackAppMessengerInterface and MTH_SlackAppMesengerMock
public with sharing class MTH_SlackAppMessenger implements MTH_SlackAppMessengerInterface {
    public Id sendMethodDueMessages(List<Methods__c> methodsDue) {
        return System.enqueueJob(new MTH_MethodDueMsgSender(methodsDue));
    }

    public Id sendMethodAssignedMessages(List<Methods__c> methodsAssigned) {
        return System.enqueueJob(new MTH_MethodsAssignMsgSender(methodsAssigned));
    }

    public Id sendKickOffMessages(List<Project_Assignment__c> projectAssignments) {
        return System.enqueueJob(new MTH_KickOffMsgHandler(projectAssignments));
    }

    public Id sendSetupMessages(List<Project_Assignment__c> projectAssignments) {
        return System.enqueueJob(new MTH_SetupMsgHandler(projectAssignments));
    }

    public Id sendWelcomeMessages(List<Project_Assignment__c> projectAssignments) {
        return System.enqueueJob(new MTH_WelcomeMsgHandler(projectAssignments));
    }

    public Id sendSmartsheetMessages(List<Project_Assignment__c> projectAssignments) {
        return System.enqueueJob(new MTH_SmartSheetLinkMsg(projectAssignments));
    }

    public Id sendGenericMessages(List<MTH_MessagePayload> payloads){
        return System.enqueueJob(new MTH_GenericMsgHandler(payloads));
    }
}