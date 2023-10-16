@isTest
public with sharing class MTH_TestSlackChannelSetup {
    private static MTH_SlackApiHandlerMock slackApiMock;
    private static PSA_Project__c testPSAProject;
    private static String teamId;
    private static String userId;

    private static void setup() {

        teamId = 'teamid';
        userId = 'userid';

        Opportunity testOpportunity = new Opportunity(
            Id = MockSObjectBuilder.getMockId(Opportunity.getSObjectType()),
            Name = 'test opportunity'
        );

        testPSAProject = new PSA_Project__c(
            Id = MockSObjectBuilder.getMockId(PSA_Project__c.getSObjectType()),
            Name = 'mock psa project',
            End_Date__c = Date.today(),
            Opportunity__r = testOpportunity
        );

        slackApiMock = new MTH_SlackApiHandlerMock();

        Slack.ConversationsCreateResponse expectedResp = new Slack.ConversationsCreateResponse();
        Slack.Conversation expectedChannel = new Slack.Conversation();
        expectedChannel.setId('channelid');
        expectedResp.setChannel(expectedChannel);
        expectedResp.setOk(true);
        expectedResp.setError(null);
        
        slackApiMock.channelCreateExpectedResponse = expectedResp;

        Slack.ConversationsCreateResponse expectedRespUser = new Slack.ConversationsCreateResponse();
        expectedRespUser.setChannel(expectedChannel);
        expectedRespUser.setOk(true);
        expectedRespUser.setError(null);
        slackApiMock.channelCreateAsUserExpectedResponse = expectedRespUser;
        MTH_SlackChannelSetup.slackApiHander = slackApiMock;
    }

    @isTest
    static void initChannel_shouldCreateChannel() {
        setup();
        
        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        Test.stopTest();
        System.assertEquals('channelid', channelId);
    }

    @isTest
    static void initChannel_shouldCreateChannelWithExpectedName() {
        setup();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();

        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        System.assertEquals('proj-proserv-test-opportunity|false', slackApiMock.channelCreateCalls[0], 'should create channel with expected name and privacy');
    }

    @isTest
    static void initChannel_shouldCreateChannelWithExpectedNameSlackConventions() {
        setup();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        testPSAProject.Opportunity__r.Name = 'opp-% $ 123';
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        System.assertEquals('proj-proserv-opp-123|false', slackApiMock.channelCreateCalls[0], 'should create channel with expected name and privacy');
    }

    @isTest
    static void initChannel_shouldCreateChannelWithExpectedNameWhenNoOpportunity() {
        setup();
        testPSAProject.Opportunity__r = null;
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();

        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        System.assertEquals('proj-proserv-mock-psa-project|false', slackApiMock.channelCreateCalls[0], 'should create channel with expected name and privacy');
    }

    @isTest
    static void initChannel_shouldFallbackWhenFailedToCreateAsUser() {
        setup();
        slackApiMock.channelCreateAsUserExpectedResponse.setError('not_authed');
        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        Test.stopTest();
        System.assertEquals('channelid', channelId);
        System.assertEquals(2, slackApiMock.channelCreateCalls.size(),'should invoke twice');
    }

    @isTest
    static void initChannel_shouldInviteUserWhenCreatedAsBot() {
        setup();
        slackApiMock.channelCreateAsUserExpectedResponse.setError('not_authed');

        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        Test.stopTest();
        System.assertEquals('channelid|userid', slackApiMock.channelInviteCalls[0],'should invite user to the created channel');
    }

    @isTest
    static void initChannel_returnsNullWhenFallbackCreationFails() {
        setup();
        slackApiMock.channelCreateAsUserExpectedResponse.setError('not_authed');
        slackApiMock.channelCreateExpectedResponse.setError('missing_scope');
        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);
        Test.stopTest();
        System.assertEquals(null, channelId);
        System.assertEquals(0, slackApiMock.channelInviteCalls.size(),'should not invite user to the channel');
    }

    @isTest
    static void initChannel_generatesRandomSuffix() {
        setup();
        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, true);
        Test.stopTest();
        
        Boolean patternMatchTest = Pattern.matches('proj-proserv-test-opportunity-[a-z\\d]{7}\\|false', slackApiMock.channelCreateCalls[0]);
        
        System.assert(patternMatchTest, 'channel name should have a random suffix');
    }

    @isTest
    static void initChannel_throwsErrorWhenChannelNameTaken() {
        setup();
        slackApiMock.channelCreateAsUserExpectedResponse.setError('name_taken');
        MTH_SlackApiErrors.ChannelCreateException expectedException;
        Test.startTest();
        MTH_SlackChannelSetup channelSetup = new MTH_SlackChannelSetup();
        try {
            String channelId = channelSetup.initChannel(testPSAProject, teamId, userId, false);

        } catch (MTH_SlackApiErrors.ChannelCreateException e) {
            expectedException = e;
        }
        Test.stopTest();        
        System.assertEquals('proj-proserv-test-opportunity', expectedException.getChannelName(),'exception should contain channel name');
        System.assertEquals('name_taken', expectedException.getError(),'exception should contain the right error');
    }
}