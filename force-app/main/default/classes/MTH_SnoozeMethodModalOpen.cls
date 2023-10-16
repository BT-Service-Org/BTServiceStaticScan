public with sharing class MTH_SnoozeMethodModalOpen extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();

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
            Id methodsId = (Id) parameters.get('methodsId');
            String viewType = String.valueOf(parameters.get('viewType'));
            return buildModal(methodsId, projectId, viewType);
        }
    }

    public class MethodNotFoundException extends Exception {
    }

    public static Slack.ModalView buildModal(Id methodId, Id projectId, String viewType) {
        Slack.ViewReference viewReference = Slack.View.mth_snooze_method_modal.get();
        viewReference.setParameter('methodId', (String) methodId);
        viewReference.setParameter('viewType', viewType);

        List<Methods__c> retrievedMethods = methodsDA.getMethodsStatus(new Set<Id>{ methodId });
        if (retrievedMethods.size() != 1) {
            throw new MethodNotFoundException(
                'Didn\'t find the needed method for the methods id: ' + methodId
            );
        }
        Methods__c selectedMethod = retrievedMethods[0];

        Date startDate = selectedMethod.Start_Date__c;
        if (startDate == null) {
            startDate = Date.today();
        }
        String formattedDate = startDate.year() + '-' + startDate.month() + '-' + startDate.day();
        viewReference.setParameter('startDate', formattedDate);
        viewReference.setParameter('projectId', projectId);
        viewReference.setParameter('changeDateOptions', getPicklistOptionsForSnoozing());

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    private static List<Slack.Option> getPicklistOptionsForSnoozing() {
        List<Slack.Option> pickListOptions = new List<Slack.Option>();
        Schema.DescribeFieldResult fieldResult = Methods__c.Reason_for_Snoozing__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : pickListValues) {
            String pickListLabel = pickListVal.getLabel();
            Slack.Option option = new Slack.Option(pickListLabel, pickListLabel);
            pickListOptions.add(option);
        }
        return pickListOptions;
    }
}