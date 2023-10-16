public with sharing class MTH_MethodOverflowHandler extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MethodDAI methodDA = new MethodDataAccessor();
    private static MTH_Pagination paginator = new MTH_Pagination();

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        Slack.ActionPayload actionPayload = context.getActionPayload();
        String identifier = String.valueOf(actionPayload.getValue());
        if (identifier.startsWith('view-details')) {
            return Slack.ActionHandler.pushModal(new ViewDetailsHandler(parameters, context));
        } else if (identifier.startsWith('complete-method-')) {
            return Slack.ActionHandler.modal(new CompleteMethodHandler(parameters, context));
        } else if (identifier.startsWith('assign-method-')) {
            return Slack.ActionHandler.modal(new AssignMethodHandler(parameters, context));
        } else if (identifier.startsWith('change-date-')) {
            return handleSnoozeAction(parameters, context);
        } else if (identifier.startsWith('mark-deliverable-') || identifier.startsWith('unmark-deliverable-')) {
            return Slack.ActionHandler.updateModal(new ToggleSOWDeliverableHandler(parameters, context));
        }else {
            return Slack.ActionHandler.updateModal(new DeleteMethodHandler(parameters, context));
        }
    }

    private Slack.ActionHandler handleSnoozeAction(Map<String, Object> parameters, Slack.RequestContext context){
    
        Map<String, Object> snoozeParameters = new Map<String, Object>{
            'projectId' => getProjectId(parameters),
            'methodsId' => getMethodId(parameters),
            'viewType' => parameters.get('viewType')
        };

        return Slack.ActionHandler.modal(new MTH_SnoozeMethodModalOpen.Handler(snoozeParameters, context));
    }

    public class ViewDetailsHandler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public ViewDetailsHandler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ActionPayload actionPayload = context.getActionPayload();
            String identifier = String.valueOf(actionPayload.getValue());
            
            String methodsId = getMethodId(parameters);

            String viewType = String.valueOf(context.getViewContext().getType());
            try {
                return MTH_MethodDetailsModalHandler.openModal(methodsId, viewType);
            } catch (Exception e) {
                return MTH_ErrorModalOpen.openModal('There was an issue retrieving the details for this method. Please contact Ops for assistance.');
            }
        }
    }

    public class CompleteMethodHandler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public CompleteMethodHandler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ActionPayload actionPayload = context.getActionPayload();
            String identifier = String.valueOf(actionPayload.getValue());
            
            String viewType = String.valueOf(parameters.get('viewType'));
            
            String projectId = getProjectId(parameters);
            Id methodsId = (Id) getMethodId(parameters);

            return MTH_MarkCompleteModalHandler.buildModal(methodsId, projectId, viewType);
        }
    }

    public class AssignMethodHandler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public AssignMethodHandler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            
            Id projectId = (Id) getProjectId(parameters);
            Id methodsId = (Id) getMethodId(parameters);

            String viewType = (String) parameters.get('viewType');
            if (String.isBlank(methodsId)){
                Slack.ActionPayload actionPayload = context.getActionPayload();
                String identifier = String.valueOf(actionPayload.getValue());
                methodsId = (Id) identifier.remove('assign-method-');
            }
            return MTH_UserSelectModalHandler.openModal(projectId, methodsId, viewType);
        }
    }

    public class DeleteMethodHandler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public DeleteMethodHandler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Id projectId = (Id) getProjectId(parameters);

            Slack.ActionPayload actionPayload = context.getActionPayload();
            String identifier = String.valueOf(actionPayload.getValue());

            if (identifier.length() == 0 || !identifier.startsWith('delete')) {
                throw new UnrecognizedActionIdentifierException(
                    identifier + ' is not a valid action identifier'
                );
            }
            String methodId = identifier.remove('delete-');
            if (methodId.length() == 0) {
                throw new NoMethodIdProvidedException('No Methods__c ID to delete');
            }
            methodsDA.deleteMethodFromProject((Id) methodId);

            Slack.ViewReference viewReference = MTH_ProjectSetupNext.getProjectSetupStepThreeViewReference(projectId);

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }
    }

    public class ToggleSOWDeliverableHandler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public ToggleSOWDeliverableHandler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            
            Id projectId = (Id) getProjectId(parameters);
            Id methodsId = (Id) getMethodId(parameters);

            try{
                List<Methods__c> methodList = methodsDA.getMethodinSOWandDeliverable(methodsId);
    
                if(methodList[0].Method_in_SOW__c){
                    methodList[0].Method_in_SOW__c = false;
                    methodList[0].Deliverable_by__c = null;
        
                } else {
                    methodList[0].Method_in_SOW__c = true;
                    methodList[0].Deliverable_by__c = 'Salesforce Deliverable';
                }
                methodsDA.updateMethods(methodList);
    
            } catch (Exception e){
    
                throw new MethodNotFoundException('Did not find method');
            }

            Slack.ViewReference viewReference = MTH_ProjectSetupNext.getProjectSetupStepThreeViewReference(projectId);

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }
    }

    private static String getProjectId(Map<String, Object> parameters){
        String ids = (String)parameters.get('ids');
        return ids.split('-')[0];
    }

    private static String getMethodId(Map<String, Object> parameters){
        String ids = (String)parameters.get('ids');
        return ids.split('-')[1];
    }

    public class UnrecognizedActionIdentifierException extends Exception {
    }

    public class NoMethodIdProvidedException extends Exception {
    }

    public class MethodNotFoundException extends Exception {
    }
}