public with sharing class MTH_AddMethodsToMethodMgmtModal extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();
    private static MTH_Pagination paginator = new MTH_Pagination();

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Id projectId = (Id) parameters.get('projectId');
            List<Id> methodsToAdd = getMethodIdsFromContext(context);

            addMethodsToProject(projectId, methodsToAdd);

            Slack.ViewReference viewReference = MTH_ProjectSetupNext.getProjectSetupStepThreeViewReference(projectId);

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }

        private void addMethodsToProject(Id projectId, List<Id> methodsToAdd) {
            List<Methods__c> methodsToInsert = new List<Methods__c>();
            for (Id m : methodsToAdd) {
                methodsToInsert.add(new Methods__c(PSA_Project__c = projectId, Method__c = m));
            }

            methodsDA.addMethodsForProject(methodsToInsert);
        }

        private List<Id> getMethodIdsFromContext(Slack.RequestContext context) {
            List<Object> methodsToAddObjects = (List<Object>) context.getFormData()
                .get('methods_lookup');

            List<Id> methodsToAdd = new List<Id>();
            for (Object m : methodsToAddObjects) {
                methodsToAdd.add((Id) m);
            }

            return methodsToAdd;
        }
    }
}