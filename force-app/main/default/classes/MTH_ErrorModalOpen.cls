public with sharing class MTH_ErrorModalOpen extends Slack.ActionDispatcher {
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
            return openModal(String.valueOf(parameters.get('errorMessage')));
        }
    }

    public static Slack.ModalView openModal(String errorMessage){
        Slack.ViewReference viewReference = Slack.View.mth_error_modal.get();
        viewReference.setParameter('error', errorMessage);

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }
}