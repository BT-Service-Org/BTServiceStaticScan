public with sharing class MTH_ProjectSetupButtonClickHandler extends Slack.ActionDispatcher {

    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
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
            Id projectId = (Id) parameters.get('projectId');
            //Code to update the status on clicking of setup project  
            PSA_Project__c projRec = projectDA.getPSAProjectAndOpportunityByProjectId(new Set<Id>{projectId})[0];
            if(projRec.Project_Setup_Status__c == Label.Project_Status_Welcome_Sent)
            {
                updateProjectSetupStatus(projRec,Label.Project_Status_Welcome_Sent_And_Opened);
            }

            return MTH_ProjectSetupModalOpen.openModal(projectId);
        }
    }

    private static void updateProjectSetupStatus(PSA_Project__c project, String status){
        project.Project_Setup_Status__c = status;
        projectDA.updateProjects(new List<PSA_Project__c>{project});
    }
}