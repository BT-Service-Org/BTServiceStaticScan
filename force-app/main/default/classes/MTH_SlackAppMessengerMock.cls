@isTest
public with sharing class MTH_SlackAppMessengerMock implements MTH_SlackAppMessengerInterface {
    public Integer callsToMethodsDue = 0;
    public Id sendMethodDueMessages(List<Methods__c> methodsDue) {
        callsToMethodsDue++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.SObjectType);
    }

    public Integer callsToMethodsAssigned = 0;
    public Id sendMethodAssignedMessages(List<Methods__c> methodsAssigned) {
        callsToMethodsAssigned++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.SObjectType);
    }

    public Integer callsToKickoff = 0;
    public Id sendKickOffMessages(List<Project_Assignment__c> projectAssignments) {
        callsToKickoff++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.SObjectType);
    }

    public Integer callsToSetup = 0;
    public Id sendSetupMessages(List<Project_Assignment__c> projectAssignments) {
        callsToSetup++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.SObjectType);
    }

    public Integer callsToWelcome = 0;
    public Id sendWelcomeMessages(List<Project_Assignment__c> projectAssignments) {
        callsToWelcome++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.SObjectType);
    }

    public Integer callsToSmartsheetUpdate = 0;
    public Id sendSmartsheetMessages(List<Project_Assignment__c> projectAssignments) {
        callsToSmartsheetUpdate++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.getSObjectType());
    }

    public Integer callsToGenericMsg = 0;
    public Id sendGenericMessages(List<MTH_MessagePayload> payloads) {
        callsToGenericMsg++;
        return MockSObjectBuilder.getMockId(AsyncApexJob.getSObjectType());
    }
}