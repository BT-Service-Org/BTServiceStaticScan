public with sharing class MTH_SnoozeMethod extends Slack.ActionDispatcher {
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

        public void run() {
            Id methodId = (Id) parameters.get('methodId');
            String viewType = String.valueOf(parameters.get('viewType'));

            List<Methods__c> retrievedMethdods = methodsDA.getMethodsStatus(
                new Set<Id>{ methodId }
            );
            if (retrievedMethdods.size() != 1) {
                throw new MethodsNotFoundException('Did not find a method to change date');
            }
            Methods__c snoozedMethod = retrievedMethdods[0];
            snoozedMethod.Start_Date__c = Date.valueOf(
                (String) context.getFormData().get('changeDate')
            );
            snoozedMethod.Reason_for_Snoozing__c = (String) context.getFormData().get('change-date-reason');
            methodsDA.updateMethods(new List<Methods__c>{ snoozedMethod });

            if (viewType == 'home') {
                String teamId = context.getTeamId();
                Id projectId = (Id) parameters.get('projectId');
                String slackId = MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(
                    context
                );
                MTH_ManageProjectViewOpen.buildHomeView(projectId, teamId, slackId);
            }
        }
    }

    public class MethodsNotFoundException extends Exception {
    }
}