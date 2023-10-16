public with sharing class MTH_UserSelectModalHandler  extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static ProjectAssignmentDAI projectAssignmentDA = new ProjectAssignmentDataAccessor();
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.modal(new MTH_MethodOverflowHandler.AssignMethodHandler(parameters, context));
    }
    
    public static Slack.ModalView openModal(Id projectId, Id methodsId, String viewType){
        Slack.ViewReference viewReference = Slack.View.mth_user_select_modal.get();
        Methods__c[] methods = methodsDA.getMethodsByMethodsIds(new Set<Id>{methodsId});
        viewReference.setParameter('methodsId', methodsId);
        viewReference.setParameter('methodName', 'to ' + methods[0].Method__r.Name);
        viewReference.setParameter('assignedResource', methods[0].Assigned_Resource__c);
        viewReference.setParameter('projectId', projectId);
        viewReference.setParameter('viewType', viewType);
        viewReference.setParameter('projectAssignments', getProjectAssignmentUserOptionsByProjectId(projectId));
        viewReference.setParameter('currentUserIsAssigned', methods[0].Assigned_Resource__c == UserInfo.getUserId());

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    public static List<Slack.Option> getProjectAssignmentUserOptionsByProjectId(Id projectId) {
        Project_Assignment__c[] projectAssignments = projectAssignmentDA.getProjectAssignmentsByProjectId(
            new Set<Id>{ projectId }
        );


        List<Slack.Option> slackUserOptions = new List<Slack.Option>();

        if (projectAssignments != null) {
            for (Project_Assignment__c projectAssignment : projectAssignments) {
                String optionLabel = projectAssignment.Resource_Name__c;
                if (String.isNotBlank(projectAssignment.Project_Role__c)) {
                    optionLabel += ' (' + projectAssignment.Project_Role__c + ')';
                }

                Slack.Option option = new Slack.Option(
                    optionLabel,
                    projectAssignment.Resource__r.User_Record__c
                );
                if (String.isNotBlank(projectAssignment.Resource_Name__c) && String.isNotBlank(projectAssignment.Resource__r.User_Record__c)) {
                    slackUserOptions.add(option);
                }
            }
        }


        return slackUserOptions;
    }
}