public with sharing class MTH_MarkCompleteModalOpen extends Slack.ActionDispatcher {
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
            return MTH_MarkCompleteModalHandler.buildModal(
                (Id) parameters.get('methodId'),
                String.valueOf(parameters.get('projectId')),
                String.valueOf(parameters.get('viewType'))
            );
        }
    }

    public class MethodNotFoundException extends Exception {
    }
    public static Slack.ModalView buildModal(Id methodId) {
        List<Methods__c> methods = methodsDA.getMethodsByMethodsIds(new Set<Id>{ methodId });
        if (methods.size() != 1) {
            throw new MethodNotFoundException();
        }
        Methods__c m = methods[0];
        Slack.ViewReference viewReference = Slack.View.mth_complete_method_modal.get();

        DateTime now = DateTime.now();
        String formattedToday = now.format('yyyy-MM-dd');
        viewReference.setParameter('today', formattedToday);
        viewReference.setParameter('methodId', methodId);
        viewReference.setParameter('methodName', m.Name);
        String servicesOrgDomain = Methodologies_Slack_App_Settings__c.getInstance()
            .Services_Org_URL__c;
        viewReference.setParameter('servicesOrgUrl', servicesOrgDomain);

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }
}