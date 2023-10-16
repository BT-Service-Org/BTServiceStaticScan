public with sharing class MTH_UserSelectSubmit extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
      
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
      
        public void run () {
            Id userId = (Id) context.getFormData().get('assign-user-select-name');

            // if action came from mth_manage_project.view, check ActionPayload for userId
            Slack.ActionPayload actionPayload = context.getActionPayload();
            if (actionPayload != null && actionPayload.getName().equals('assign-user-select-name')) {
                userId = (Id)actionPayload.getValue();
            }

            Id methodsId = (Id) parameters.get('methodsId');
            String viewType = (String) parameters.get('viewType');
            Methods__c methodsToUpdate = (methodsDA.getMethodsByMethodsIds(new Set<Id>{methodsId})).get(0);
            methodsToUpdate.OwnerId = userId;
            methodsToUpdate.Assigned_Resource__c = userId;
            methodsDA.updateMethods(new List<Methods__c>{methodsToUpdate});

            // refreshes project manage home view with current information
            // else statement not necessary
            if (viewType == 'home') {
                String teamId = context.getTeamId();
                Id projectId = (Id)parameters.get('projectId');
                String slackId = MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(context);
                MTH_ManageProjectViewOpen.buildHomeView(projectId, teamId, slackId);
            }
        }
    }
}