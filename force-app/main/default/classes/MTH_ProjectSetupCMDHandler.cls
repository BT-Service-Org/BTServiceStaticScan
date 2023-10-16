public with sharing class MTH_ProjectSetupCMDHandler extends Slack.SlashCommandDispatcher {
    public override Slack.ActionHandler invoke(
        Slack.SlashCommandParameters parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.modal(new Handler(parameters, context), 'Project Setup');
    }

    public class Handler implements Slack.ModalHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            String projectIdInput = parameters.getText();
            Id projectId;

            try {
                projectId = (Id) projectIdInput;
            } catch (Exception e) {
                return openErrorModal();
            }

            if (String.isBlank(projectIdInput) || projectId.getSobjectType() != PSA_Project__c.getSObjectType()) {
                return openErrorModal();
            }

            Slack.ModalView modalView = MTH_ProjectSetupModalOpen.openModal(projectId);
            return modalView;
        }
    }

    private static Slack.ModalView openErrorModal() {
        return MTH_ErrorModalOpen.openModal('To start setting up your project, make sure the slash command is followed by the PSA Project Id. \n\n`/methodologies-project-setup [your-project-id]`');
    }
}