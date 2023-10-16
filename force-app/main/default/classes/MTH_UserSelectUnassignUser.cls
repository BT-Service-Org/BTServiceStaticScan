public with sharing class MTH_UserSelectUnassignUser extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static ProjectAssignmentDAI projectAssignmentDA = new ProjectAssignmentDataAccessor();
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MTH_SlackAppMessengerInterface messenger = new MTH_SlackAppMessenger();

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
            Id userId = (Id) parameters.get('assignedResource');
            Id projectId = (Id) parameters.get('projectId');
            Id methodsId = (Id) parameters.get('methodsId');
            Id projectManagerId = getProjectManagerByProjectId(projectId);
            String viewType = (String) parameters.get('viewType');
            Methods__c methodsToUpdate = (methodsDA.getMethodsByMethodsIds(
                    new Set<Id>{ methodsId }
                ))
                .get(0);

            if (projectManagerId != null){
                methodsToUpdate.OwnerId = projectManagerId;
            }

            methodsToUpdate.Assigned_Resource__c = projectManagerId;
            methodsDA.updateMethods(new List<Methods__c>{ methodsToUpdate });

            sendMethodAssignmentMessage(methodsId);

            Slack.ViewReference viewReference = Slack.View.mth_confirmation_modal.get();
            return new Slack.ModalView.Builder().viewReference(viewReference).build();
        }
    }

    private static Id getProjectManagerByProjectId(Id projectId) {
        PSA_Project__c[] projects = psaProjectDA.getPSAProjectByProjectId(
            new Set<Id>{ projectId }
            );
            PSA_Project__c project = projects[0];
            
        return project.Project_Manager__r.User_Record__c;
    }

    @future(callout=true)
    private static void sendMethodAssignmentMessage(Id methodsId) {
        List<Methods__c> methods = methodsDA.getMethodsByMethodsIds(new Set<Id>{ methodsId });
        messenger.sendMethodAssignedMessages(methods);
    }
}