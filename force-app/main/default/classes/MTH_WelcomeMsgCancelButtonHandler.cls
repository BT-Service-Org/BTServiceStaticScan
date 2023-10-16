public with sharing class MTH_WelcomeMsgCancelButtonHandler extends Slack.ActionDispatcher {
    @testVisible
    private static MTH_SlackApiHandlerInterface slackApiHandler = new MTH_SlackApiHandler();
    @testVisible
    private static String ts = null;

    private static String getTs(Slack.RequestContext context) {
        if (!String.isBlank(ts)) {
            return ts;
        }
        //below line fails in test context.
        return context.getMessageContext().getTs();
    }

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }
        private Map<String, String> getTextConfig() {
            List<Methodologies_Slack_App_Message_Text__mdt> configuredMessageTexts = Methodologies_Slack_App_Message_Text__mdt.getAll()
                .values();

            Map<String, String> textConfig = new Map<String, String>();
            for (Methodologies_Slack_App_Message_Text__mdt m : configuredMessageTexts) {
                if (m.Message__c == 'Welcome Message Cancel' || String.isBlank(m.Message__c)) {
                    textConfig.put(m.Section__c, m.Text__c);
                }
            }
            return textConfig;
        }

        public void run() {
            String channelId = context.getChannelId();
            String ts = getTs(context);

            Slack.ViewReference newMessage = Slack.View.mth_msg_welcome_cancel.get();
            newMessage.setParameter('textConfig', getTextConfig());
            System.debug(getTextConfig());
            slackApiHandler.updateMessage(newMessage, channelId, ts);
        }
    }
}