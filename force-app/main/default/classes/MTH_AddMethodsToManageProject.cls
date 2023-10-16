public with sharing class MTH_AddMethodsToManageProject extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MethodByGroupingDAI methodByGroupingDA = new MethodByGroupingDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();

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

            Id projectId = (Id) parameters.get('projectId');
            List<Id> methodsToAdd = getMethodIdsFromContext(context);
            addMethodsToProject(projectId, methodsToAdd);

            String viewType = (String) parameters.get('viewType');

            if (viewType == 'home') {
                String teamId = context.getTeamId();
                String slackId = MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(context);
                MTH_ManageProjectViewOpen.buildHomeView(projectId, teamId, slackId);
            }

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