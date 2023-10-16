@IsTest
public with sharing class MethodologyTestHelper {
    public static final String TEST_PROJECT_NAME= 'Test Project';
    public static final String TEST_PROJECT_ROLE_MANAGER= 'Project Manager';
    public static final String TEST_PROJECT_ROLE_DEVELOPER= 'Developer';

    public static void setupBaseDataForSlackTriggerBatch(){
        PSA_Project__c project = new PSA_Project__c();
        project.Name = TEST_PROJECT_NAME;
        project.Start_Date__c = Date.today();
        project.Project_Setup_Status__c = 'Not Started';
        project.SmartSheet_Link__c='https://google.com';
        insert project;

        Contact contact  = new Contact(FirstName='Test', LastName='Contact',User_Record__c = UserInfo.getUserId());
        insert contact;

        Contact contact2  = new Contact(FirstName='Test2', LastName='Contact2',User_Record__c = UserInfo.getUserId());
        insert contact2;

        Methods__c method = new Methods__c();
        method.PSA_Project__c = project.Id;
        method.Start_Date__c = Date.today();
        method.End_Date__c = Date.today()+1;
        method.assigned_Resource__c = UserInfo.getUserId();
        insert method;

        Project_Assignment__c assignment = new Project_Assignment__c();
        assignment.Resource__c = contact.Id;
        assignment.Project_Role__c = TEST_PROJECT_ROLE_MANAGER;
        assignment.PSA_Project__c = project.Id;
        assignment.Start_Date__c = Date.today();
        assignment.Org62_Id__c = 'testId';
        insert assignment;

        Project_Assignment__c assignment2 = new Project_Assignment__c();
        assignment2.Resource__c = contact2.Id;
        assignment2.Project_Role__c = TEST_PROJECT_ROLE_DEVELOPER;
        assignment2.PSA_Project__c = project.Id;
        assignment2.Start_Date__c = Date.today();
        assignment2.Org62_Id__c = 'testId2';
        insert assignment2;
    }

    public static MTH_SlackApiHandlerInterface createMockSlackApiHandler(){
        Mock_MTH_SlackApiHandler mockHandler =  new Mock_MTH_SlackApiHandler();
        return mockHandler;
    }

    public static void updateProjectSetupStatus(String status){
        PSA_Project__c proj = [SELECT Project_Setup_Status__c FROM PSA_Project__c WHERE Name = :MethodologyTestHelper.TEST_PROJECT_NAME];
        proj.Project_Setup_Status__c = status;
        update proj;
    }

    public class Mock_MTH_SlackApiHandler implements MTH_SlackApiHandlerInterface {

        public boolean isPostMessageCalled = false;

        public Slack.User getUserByEmail(String email){
             throw new MTH_SlackApiErrors.UserLookupByEmailException();
         }
        public string postMessage(Slack.ViewReference view, String channelId){
             isPostMessageCalled = true;
             return '';
         }
        public String postMessage(String text, String channelId) {
            return '';
        }
        public List<String> channelsPinnedSentMessage = new List<String>();
        public String postPinnedMessageExpectedResult = 'msg-ts';
        public String postPinnedMessage(Slack.ViewReference view, String channelId) {
            channelsPinnedSentMessage.add(channelId);
            return postPinnedMessageExpectedResult;
        }
    
        public List<Slack.ViewReference> messageViewsSent = new List<Slack.ViewReference>();
        public void postErrorOrConfirmationMessage(Slack.ViewReference view) {
            messageViewsSent.add(view);
            return;
        }
    
        public List<String> updateMessageChannelIdTsCalls = new List<String>();
        public void updateMessage(Slack.ViewReference view, String channelId, String ts) {
            updateMessageChannelIdTsCalls.add(channelId + '|' + ts);
            return;
        }
    
        public List<String> channelInviteCalls = new List<String>();
        public void inviteUsersToChannelWithRetry(String channelId, String invitingUserId, String teamId, List<String> users){
            channelInviteCalls.add(channelId+'|'+String.join(users,','));
            return;
        }
    
        public void inviteUsersToChannelWithRetry(String channelId, String teamId, List<String> users){
            channelInviteCalls.add(channelId+'|'+String.join(users,','));
            return;
        }
    
        public List<String> channelCreateCalls = new List<String>();
        public Slack.ConversationsCreateResponse channelCreateExpectedResponse = new Slack.ConversationsCreateResponse();
        public Slack.ConversationsCreateResponse channelCreateAsUserExpectedResponse = new Slack.ConversationsCreateResponse();
        public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate){
            channelCreateCalls.add(name+'|'+isPrivate);
            return channelCreateExpectedResponse;
        }
    
        public Slack.ConversationsCreateResponse createChannel(String name, Boolean isPrivate, String userId){
            channelCreateCalls.add(name+'|'+isPrivate);
            return channelCreateAsUserExpectedResponse;
        }
        
     }
}