public with sharing class MTH_SettingsModalOpen extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.modal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ViewReference viewReference = Slack.View.mth_settings_modal.get();
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            viewReference.setParameter('url', settings.Services_Org_URL__c);
            return new Slack.ModalView.Builder().viewReference(viewReference).build();
        }
    }
}