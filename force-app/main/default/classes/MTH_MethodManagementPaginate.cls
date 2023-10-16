public with sharing class MTH_MethodManagementPaginate extends Slack.ActionDispatcher {
    @testVisible
    private static MTH_Pagination paginator = new MTH_Pagination();
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();

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
            Slack.ActionPayload actionPayload = context.getActionPayload();

            String projectId = (String) parameters.get('projectId');
            String projectTitle = (String) parameters.get('projectTitle');
            String engagementSize = (String) parameters.get('engagementSize');
            Integer setupStep = ((Long) parameters.get('setupStep')).intValue();
            String query = methodsDA.getMethodsByPSAProjectIdStringQuery(projectId);
            String orderBy = 'Method__r.Name';

            Map<Object, Object> prevPaginatorParam = (Map<Object, Object>) ((List<Object>) parameters.get(
                    'paginator'
                ))
                .iterator()
                .next();

            // handle user selecting a specific page to go to
            Boolean jumpToPage = false;
            if (context.getFormData() != null) {
                for (String key : context.getFormData().keySet()) {
                    Object value = context.getFormData().get(key);
                    if (key.equals('method_page_select') && value != null) {
                        prevPaginatorParam.put('currPage', Integer.valueOf(value) - 1);
                        jumpToPage = true;
                        break;
                    }
                }
            }

            Integer currPage = Integer.valueOf(prevPaginatorParam.get('currPage'));

            if (actionPayload.getName() == paginator.NEXT_PAGE || jumpToPage) {
                Slack.ViewReference viewReference = nextPage(
                    actionPayload,
                    projectId,
                    projectTitle,
                    query,
                    orderBy,
                    prevPaginatorParam,
                    currPage,
                    engagementSize,
                    setupStep
                );

                Slack.ModalView modalView = new Slack.ModalView.Builder()
                    .viewReference(viewReference)
                    .build();
                return modalView;
            }

            Slack.ViewReference viewReference = prevPage(
                actionPayload,
                projectId,
                projectTitle,
                query,
                orderBy,
                prevPaginatorParam,
                currPage,
                engagementSize,
                setupStep
            );

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .build();
            return modalView;
        }

        private Slack.ViewReference nextPage(
            Slack.ActionPayload actionPayload,
            String projectId,
            String projectTitle,
            String query,
            String orderBy,
            Map<Object, Object> prevPaginatorParam,
            Integer currPage,
            String engagementSize,
            Integer setupStep
        ) {
            Map<Integer, List<SObject>> methodsForProject = paginator.getNextPage(
                query,
                orderBy,
                currPage
            );

            Integer totalPages = Integer.valueOf(prevPaginatorParam.get('totalPages'));
            currPage = methodsForProject.keySet().iterator().next();
            Boolean hasNextPage = paginator.hasNextPage(query, orderBy, currPage);
            Boolean hasPrevPage = paginator.hasPreviousPage(query, orderBy, currPage);
            List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
                hasNextPage,
                hasPrevPage,
                currPage,
                totalPages
            );

            Slack.ViewReference viewReference;
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();

            if (setupStep == 3) {
                PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{ projectId });
                PSA_Project__c project = projects[0];
                viewReference = Slack.View.mth_proj_setup_mthd_manage_modal.get();
                viewReference.setParameter('projectTitle', projectTitle);
                viewReference.setParameter('projectUrl', MTH_ProjectUtils.getProjectUrl(project, settings));
            }

            viewReference.setParameter('projectId', projectId);
            viewReference.setParameter('methods', MTH_ProjectSetupNext.createMethodsMapList(engagementSize, methodsForProject.get(currPage)));
            viewReference.setParameter('paginator', paginatorParam);
            viewReference.setParameter('engagementSize', engagementSize);

            return viewReference;
        }

        private Slack.ViewReference prevPage(
            Slack.ActionPayload actionPayload,
            String projectId,
            String projectTitle,
            String query,
            String orderBy,
            Map<Object, Object> prevPaginatorParam,
            Integer currPage,
            String engagementSize,
            Integer setupStep
        ) {
            Map<Integer, List<SObject>> methodsForProject = paginator.getPreviousPage(
                query,
                orderBy,
                currPage
            );

            Integer totalPages = Integer.valueOf(prevPaginatorParam.get('totalPages'));
            currPage = methodsForProject.keySet().iterator().next();
            Boolean hasNextPage = paginator.hasNextPage(query, orderBy, currPage);
            Boolean hasPrevPage = paginator.hasPreviousPage(query, orderBy, currPage);

            List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
                hasNextPage,
                hasPrevPage,
                currPage,
                totalPages
            );

            Slack.ViewReference viewReference;
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();

            if (setupStep == 3) {
                PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{ projectId });
                PSA_Project__c project = projects[0];
                viewReference = Slack.View.mth_proj_setup_mthd_manage_modal.get();
                viewReference.setParameter('projectTitle', projectTitle);
                viewReference.setParameter('projectUrl', MTH_ProjectUtils.getProjectUrl(project, settings));
            }

            viewReference.setParameter('projectId', projectId);
            viewReference.setParameter('methods', MTH_ProjectSetupNext.createMethodsMapList(engagementSize, methodsForProject.get(currPage)));
            viewReference.setParameter('paginator', paginatorParam);
            viewReference.setParameter('engagementSize', engagementSize);

            return viewReference;
        }
    }
}