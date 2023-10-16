public with sharing class MTH_MethodDetailsModalOpen extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();

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
            String viewType;
             if (context.getViewContext() != null){
                viewType = String.valueOf(context.getViewContext().getType());
             } else {
                viewType = 'message';
             }

            try {
                return MTH_MethodDetailsModalHandler.openModal((Id) parameters.get('methodId'), viewType);
            } catch (Exception e) {
                return MTH_ErrorModalOpen.openModal('There was an issue retrieving the details for this method. Please contact Ops for assistance.');
            }
        }
    }
}