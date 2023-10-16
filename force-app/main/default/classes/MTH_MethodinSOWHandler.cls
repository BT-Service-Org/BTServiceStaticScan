public with sharing class MTH_MethodinSOWHandler extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MTH_PaginationInterface paginator = new MTH_Pagination();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    private static void updateStar(Id method){
        try{
            List<Methods__c> methodList = methodsDA.getMethodinSOWandDeliverable(method);

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
            PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{projectId});
            PSA_Project__c project = projects[0];
            Id methodId;
            try {
                methodId = (Id) parameters.get('methodId');
            } catch (Exception e) {
                Map<Object, Object> methodIdMap = (Map<Object, Object>) parameters.get('methodId');
                methodId = (Id) methodIdMap.get('value');
            }

            updateStar(methodId);

            Slack.ViewReference viewReference = Slack.View.mth_proj_setup_sow_deliverables_modal.get();
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            viewReference.setParameter('projectId', project.Id);

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
            List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
                hasNextPage,
                false,
                1,
                totalPages
            );

            viewReference.setParameter('paginator', paginatorParam);
            viewReference.setParameter('engagementSize', project.Engagement_Size__c);
            List<Slack.Option> options = methodsDA.getMethodsOptionsByProjectId(projectId);
            viewReference.setParameter('options', options);
            viewReference.setParameter('org62Url', settings.Org_62_Url__c);
            viewReference.setParameter('org62OpportunityId', project.Org62_Opportunity_Id__c);
            viewReference.setParameter('methods', MTH_ProjectSetupNext.createMethodsMapList(project.Engagement_Size__c, methodsForProject.get(1)));

            Slack.ModalView modalView = new Slack.ModalView.builder()
                .viewReference(viewReference)
                .build();    
            return modalView;
        }
    } 

    
        public class MethodNotFoundException extends Exception {
    }
}