public with sharing class MTH_FeedbackModalSubmit extends Slack.ActionDispatcher {
    @testVisible
    private static MTH_SlackApiHandlerInterface slackApi = new MTH_SlackApiHandler();

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

        public void run() {
            String rating = (String) context.getFormData().get('quantitative-feedback');
            String freeform = (String) context.getFormData().get('text-feedback');

            Slack.ViewReference viewReference = Slack.View.mth_msg_feedback_notification.get();
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();

            viewReference.setParameter('rating', rating);
            viewReference.setParameter('freeformFeedback', freeform);
            viewReference.setParameter('userSlackId', context.getUserId());
            String msgTs = slackApi.postMessage(viewReference, settings.Feedback_Channel_Id__c);
            if (msgTs == null) {
                MTH_SlackMessageSender.sendErrorMessage(settings.Feedback_Channel_Id__c, '');
            } else {
                MTH_SlackMessageSender.sendConfirmationMessage(settings.Feedback_Channel_Id__c);
            }
        }
    }
}