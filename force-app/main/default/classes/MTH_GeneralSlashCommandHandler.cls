public with sharing class MTH_GeneralSlashCommandHandler extends Slack.SlashCommandDispatcher {
    private static MTH_Pagination paginator = new MTH_Pagination();
    public override Slack.ActionHandler invoke(
        Slack.SlashCommandParameters parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.modal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            String paramText = parameters.getText()?.trim();
            if (paramText?.endsWith('openTestModal') == true) {
                return buildTestModal();
            }
            if (paramText?.endsWith('feedback') == true) {
                return buildFeedbackModal();
            }
            //defaults to test modal for now; this will not be permanent
            return buildQuickMenuModal();
        }

        private Slack.ModalView buildTestModal() {
            Slack.ViewReference viewReference = Slack.View.mth_test_modal.get();
            viewReference.setParameter(
                'methodsId',
                MockSObjectBuilder.getMockId(Methods__c.SObjectType)
            );
            viewReference.setParameter(
                'viewType',
                'home'
            );
            viewReference.setParameter(
                'projectId',
                MockSObjectBuilder.getMockId(PSA_Project__c.SObjectType)
            );
            viewReference.setParameter(
                'userId',
                UserInfo.getUserId()
            );
            List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
                        true,
                        false,
                        1,
                        3
                    );
            viewReference.setParameter(
                'paginator',
                paginatorParam
            );
            List<Map<String, String>> prevPaginatorParam = paginator.generatePaginatorViewParam(
                        true,
                        true,
                        2,
                        3
                    );
            viewReference.setParameter(
                'previousPaginator',
                prevPaginatorParam
            );
            return new Slack.ModalView.Builder().viewReference(viewReference).build();
        }

        private Slack.ModalView buildQuickMenuModal() {
            Slack.ViewReference viewReference = Slack.View.mth_quick_menu_modal.get();
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            viewReference.setParameter('teamId', settings.Team_Id__c);
            viewReference.setParameter('appId', settings.App_Id__c);
            return new Slack.ModalView.Builder().viewReference(viewReference).build();
        }

        private Slack.ModalView buildFeedbackModal() {
            Slack.ViewReference viewReference = Slack.View.mth_feedback_modal.get();
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            viewReference.setParameter(
                'methodologiesChannelId',
                settings.General_Information_Slack_Channel_Id__c
            );
            viewReference.setParameter('userSlackId', context.getUserId());
            return new Slack.ModalView.Builder().viewReference(viewReference).build();
        }
    }
}