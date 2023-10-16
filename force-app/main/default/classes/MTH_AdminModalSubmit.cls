public with sharing class MTH_AdminModalSubmit extends Slack.ActionDispatcher {
    @testVisible
    private static ProjectAssignmentDAI assignmentDa = new ProjectAssignmentDataAccessor();
    @testVisible
    private static MTH_SlackAppMessengerInterface messenger = new MTH_SlackAppMessenger();
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static Boolean hasAdminPermission = FeatureManagement.checkPermission(
        'Methodologies_Slack_App_Admin_Modal_Access'
    );

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
            try {
                sendMessage(context);
            } catch (StringException e) {
                MTH_SlackMessageSender.sendErrorMessage('', 'Not a valid id. Double check and try again.');
            } catch (Exception e) {
                MTH_SlackMessageSender.sendErrorMessage('', '');
            }
        }

        private void sendMessage(Slack.RequestContext context){
            if (!hasAdminPermission) {
                MTH_SlackMessageSender.sendErrorMessage('', 'You do not have admin permissions. Contacts Ops for assistance.');
                throw new UserNotAdminException();
            }
            String messageToSend = (String) context.getFormData().get('message-select');
            Id recordIdForMessage = (Id) context.getFormData().get('message-record-id');

            if (recordIdForMessage.getSobjectType() == PSA_Project__c.getSObjectType()) {
                List<Project_Assignment__c> assignments = assignmentDa.getProjectAssignmentsByProjectId(
                    new Set<Id>{ recordIdForMessage }
                );
                if (messageToSend == 'kick-off') {
                    messenger.sendKickOffMessages(assignments);
                } else if (messageToSend == 'setup') {
                    PSA_Project__c proj = projectDA.getPSAProjectByProjectId(new Set<ID>{recordIdForMessage})[0];
                    for(Project_Assignment__c assignment : assignments){
                        if(assignment.Resource__c == proj.Project_Manager__c){
                            messenger.sendSetupMessages(new List<Project_Assignment__c>{assignment});
                            break;
                        }
                    }
                    
                } else if (messageToSend == 'welcome') {
                    messenger.sendWelcomeMessages(assignments);
                } else if (messageToSend == 'smartsheet-update') {
                    messenger.sendSmartsheetMessages(assignments);
                }else {
                    MTH_SlackMessageSender.sendErrorMessage('', 'The required id type and the inputted id do not match. Double check the id types and try again.');
                }
            } else if (recordIdForMessage.getSobjectType() == Methods__c.getSObjectType()) {
                List<Methods__c> methods = methodsDA
                    .getMethodsByMethodsIds(new Set<Id>{ recordIdForMessage });
                if (messageToSend == 'method-due') {                
                    messenger.sendMethodDueMessages(methods);
                } else if (messageToSend == 'method-assigned') {
                    messenger.sendMethodAssignedMessages(methods);
                }else {
                    MTH_SlackMessageSender.sendErrorMessage('', 'The required id type and the inputted id do not match. Double check the id types and try again.');
                }
            } else {
                MTH_SlackMessageSender.sendErrorMessage('', 'The required id type and the inputted id do not match. Double check the id types and try again.');
            }
            return;
        }
    }

    public class UserNotAdminException extends Exception {
    }
}