public with sharing class MTH_ProjectSetupMethodsFilter extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MTH_PaginationInterface paginator = new MTH_Pagination();
    
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }
        
        public Slack.ModalView call() {
            Slack.ViewReference viewReference = Slack.View.mth_proj_setup_sow_deliverables_modal.get();
            Slack.ActionPayload actionPayload = context.getActionPayload();
            String identifier = String.valueOf(actionPayload.getValue());
            Id projectId = (Id) parameters.get('projectId');
            PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{projectId});
            PSA_Project__c project = projects[0];

            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            viewReference.setParameter('projectId', projectId);
            viewReference.setParameter('engagementSize', project.Engagement_Size__c);
            viewReference.setParameter('org62Url', settings.Org_62_Url__c);
            viewReference.setParameter('org62OpportunityId', project.Org62_Opportunity_Id__c);
            List<Map<String, String>> paginatorParam;
            if (String.isBlank(identifier)){
                String query = methodsDA.getMethodsByPSAProjectIdStringQuery((String) projectId);
                String orderBy = 'Method__r.Name';
                Map<Integer, List<SObject>> methodsForProject = paginator.getNextPage(
                query,
                orderBy,
                0
                );
                Boolean hasNextPage = paginator.hasNextPage(query, orderBy, 1);
                Integer totalPages = paginator.totalPages(
                    methodsDA.getMethodsCountByPSAProjectIdStringQuery(project.Id)
                );
                paginatorParam = paginator.generatePaginatorViewParam(hasNextPage, false, 1, totalPages);
                List<Methods__c> methods = methodsDA.getMethodsByPSAProjectId(projectId);
                viewReference.setParameter('methods', MTH_ProjectSetupNext.createMethodsMapList(project.Engagement_Size__c, methodsForProject.get(1)));
            } else {
                paginatorParam = paginator.generatePaginatorViewParam(false, false, 1, 1);
                Set<Id> methodIdsSet = new Set<Id>{Id.valueOf(identifier)};
                List<Methods__c> methods = methodsDA.getMethodsByMethodsIds(methodIdsSet);
                viewReference.setParameter('methods', MTH_ProjectSetupNext.createMethodsMapList(project.Engagement_Size__c, methods));
            }

            List<Slack.Option> options = methodsDA.getMethodsOptionsByProjectId(Id.valueOf(projectId));
            viewReference.setParameter('options', options);
            viewReference.setParameter('paginator', paginatorParam);

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }
    }
}