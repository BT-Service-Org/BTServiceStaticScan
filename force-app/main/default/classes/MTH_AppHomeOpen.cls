/**
 * Renders app home page when opened or when user paginates through list of projects
 */
public with sharing class MTH_AppHomeOpen extends Slack.EventDispatcher {
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static ProjectAssignmentDAI assignmentDA = new ProjectAssignmentDataAccessor();
    @testVisible
    private static MTH_Pagination paginator = new MTH_Pagination(5);   // 5 project shown at a time

    public override Slack.ActionHandler invoke(
        Slack.EventParameters parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new Handler(context));
    }

    public class Handler implements Slack.RunnableHandler {
        Map<String, Object> actionParameters;
        Slack.RequestContext context;

        public Handler(Slack.RequestContext context) {
            this.context = context;
        }

        /**
         * @description Constructor called from MTH_ProjectManagementPaginate when paginating
         * @param  actionParameters pagination button action parameters
         * @param  context          pagination context
         */
        public Handler(Map<String, Object> actionParameters, Slack.RequestContext context) {
            this.actionParameters = actionParameters;
            this.context = context;
        }

        private String getProjectKey(Integer projectNumber) {
            return 'project' + String.valueOf(projectNumber);
        }
        private String getMethodKey(Integer projectNumber, Integer methodNumber) {
            return getProjectKey(projectNumber) + 'method' + String.valueOf(methodNumber);
        }

        private Map<Id, Project_Assignment__c> getUserProjectAssignmentsByProjectId() {
            List<Project_Assignment__c> assignments = assignmentDA.getProjectAssignmentsForUsers(
                new Set<Id>{ UserInfo.getUserId() }
            );
            Map<Id, Project_Assignment__c> projectAssignmentsByProjectId = new Map<Id, Project_Assignment__c>();
            for (Project_Assignment__c a : assignments) {
                projectAssignmentsByProjectId.put(a.PSA_Project__c, a);
            }
            
            return projectAssignmentsByProjectId;
        }


        /**
         * @description Get paginated list of projects and methods for current user
         * @param  projectIds project ids to query
         * @param  currPage   page to retrieve
         * @return            list of projects
         */
        private List<PSA_Project__c> getProjectsForUser(
            Set<Id> projectIds,
            Map<Object, Object> prevPaginatorParam,
            String pageAction
        ) {
            Integer currPage = (prevPaginatorParam == null)? 0 : Integer.valueOf(prevPaginatorParam.get('currPage'));
            String query = projectDA.getProjectsAndMethodsFromProjectIdsStringQuery(projectIds, UserInfo.getUserId());
            String orderBy = 'Id';

            if (pageAction == null || pageAction == paginator.NEXT_PAGE) {
                Map<Integer, List<SObject>> projectsByPage = paginator.getNextPage(
                    query,
                    orderBy,
                    currPage
                );

                return (List<PSA_Project__c>)projectsByPage.get(currPage + 1);
            } else {
                Map<Integer, List<SObject>> projectsByPage = paginator.getPreviousPage(
                    query,
                    orderBy,
                    currPage
                );

                return (List<PSA_Project__c>)projectsByPage.get(currPage - 1);
            }
        }

        private Map<String, Boolean> buildInitialProjectVisibilityMap() {
            Map<String, Boolean> projectVisibilityMap = new Map<String, Boolean>();
            for (Integer i = 1; i <= 5; i++) {
                String projectKey = getProjectKey(i);
                projectVisibilityMap.put(projectKey, false);
                for (Integer j = 1; j <= 3; j++) {
                    projectVisibilityMap.put(getMethodKey(i, j), false);
                }
                projectVisibilityMap.put(projectKey + 'moreMethods', false);
                projectVisibilityMap.put(projectKey + 'noAssignments', false);
            }
            return projectVisibilityMap;
        }

        private Map<String, String> buildMethodsMap(Methods__c m) {
            return new Map<String, String>{
                'Id' => m.Id,
                'name' => m.Method__r.Name,
                'description' => m.Method__r.Method_Headline__c,
                'dueString' => buildDueStatusText(m.End_Date__c)
            };
        }

        private void populateMethodsIntoProjectMap(
            PSA_Project__c project,
            Map<String, Map<String, String>> projectMap,
            Map<String, Boolean> projectsVisibilityMap,
            Integer projectNumber
        ) {
            Integer methodNumber = 1;
            for (Methods__c methods : project.Method_for_Projects__r) {
                String methodKey = getMethodKey(projectNumber, methodNumber);

                projectMap.put(methodKey, buildMethodsMap(methods));
                projectsVisibilityMap.put(methodKey, true);

                methodNumber++;
                if (methodNumber > 3) {
                    return;
                }
            }
        }

        private Map<String, String> buildProjectMap(
            PSA_Project__c p,
            Project_Assignment__c assignment
        ) {
            return new Map<String, String>{
                'Id' => p.Id,
                'Name' => p.Name,
                'userRole' => assignment.Project_Role__c,
                'startDate' => assignment.Start_Date__c.format(),
                'endDate' => assignment.End_Date__c.format(),
                'additionalMethods' => String.valueOf(p.Method_for_Projects__r.size() - 3),
                'url' => MTH_ProjectUtils.getProjectUrl(p, Methodologies_Slack_App_Settings__c.getInstance())
            };
        }

        private void updateProjectVisibilityMapForProject(
            PSA_Project__c project,
            Integer projectNum,
            Map<String, Boolean> projectVisibilityMap
        ) {
            String projectKey = getProjectKey(projectNum);
            List<Methods__c> methods = project.Method_for_Projects__r;

            projectVisibilityMap.put(projectKey, true);
            projectVisibilityMap.put(projectKey + 'moreMethods', methods.size() > 3);
            projectVisibilityMap.put(projectKey + 'noAssignments', methods.isEmpty());
        }

        private void populateMaps(
            Map<String, Map<String, String>> projectsMap,
            Map<String, Boolean> projectVisibilityMap,
            Map<Object, Object> prevPaginatorParam,
            String pageAction
        ) {
            Map<Id, Project_Assignment__c> assignmentsByProjectId = getUserProjectAssignmentsByProjectId();
            List<PSA_Project__c> projects = getProjectsForUser(assignmentsByProjectId.keySet(), prevPaginatorParam, pageAction);

            Integer i = 1;
            for (PSA_Project__c project : projects) {
                projectsMap.put(
                    getProjectKey(i),
                    buildProjectMap(project, assignmentsByProjectId.get(project.Id))
                );
                populateMethodsIntoProjectMap(project, projectsMap, projectVisibilityMap, i);
                updateProjectVisibilityMapForProject(project, i, projectVisibilityMap);

                i++;
            }
            projectVisibilityMap.put('noProjects', projects.isEmpty());
        }

        private Boolean showAdminModal() {
            return FeatureManagement.checkPermission('Methodologies_Slack_App_Admin_Modal_Access');
        }

        private Slack.ViewReference buildView(
            Map<String, Map<String, String>> projectsInfoMap,
            Map<String, Boolean> projectsVisibilityMap,
            Map<Object, Object> prevPaginatorParam,
            String pageAction
        ) {
            Slack.ViewReference viewReference = Slack.View.mth_home.get();

            viewReference.setParameter('projects', projectsInfoMap);
            viewReference.setParameter('projectVisibilityMap', projectsVisibilityMap);
            viewReference.setParameter('showAdminButton', showAdminModal());
            viewReference.setParameter('hideAdminButton', !showAdminModal());

            String servicesOrgDomain = Methodologies_Slack_App_Settings__c.getInstance()
                .Services_Org_URL__c;
            viewReference.setParameter('servicesOrgUrl', servicesOrgDomain);
            String KnowledgeCenterURL = Methodologies_Slack_App_Settings__c.getInstance()
            .Knowledge_Center_URL__c;
            viewReference.setParameter('knowledgeCenterURL', KnowledgeCenterURL);

            /** handle pagination */
            Integer currPage = (prevPaginatorParam == null)? 0 : Integer.valueOf(prevPaginatorParam.get('currPage'));
            Map<Id, Project_Assignment__c> assignmentsByProjectId = getUserProjectAssignmentsByProjectId();
            String query = projectDA.getProjectsAndMethodsFromProjectIdsStringQuery(assignmentsByProjectId.keySet(), UserInfo.getUserId());
            String orderBy = 'Id';

            if (pageAction == null || pageAction == paginator.NEXT_PAGE) {
                currPage += 1;
            } else {
                currPage -= 1;
            }

            Boolean hasNextPage = paginator.hasNextPage(query, orderBy, currPage);
            Boolean hasPreviousPage = paginator.hasPreviousPage(query, orderBy, currPage);
            Integer totalPages = 0;
            
            if (prevPaginatorParam == null) {
                totalPages = paginator.totalPages(
                    projectDA.getProjectsAndMethodsCountFromProjectIdsStringQuery(assignmentsByProjectId.keySet())
                );
            } else {
                totalPages = Integer.valueOf(prevPaginatorParam.get('totalPages'));
            }

            List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
                hasNextPage,
                hasPreviousPage,
                currPage,
                totalPages
            );

            viewReference.setParameter('paginator', paginatorParam);

            return viewReference;
        }

        private void publishHome(Slack.ViewReference view) {
            Slack.App app = Slack.App.Methodologies.get();
            Slack.BotClient botClient = app.getBotClientForTeam(context.getTeamId());

            Slack.HomeView homeView = new Slack.HomeView.builder().viewReference(view).build();

            Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder()
                .userId(MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(context))
                .view(homeView)
                .build();

            Slack.ViewsPublishResponse response = botClient.ViewsPublish(req);
            if (response.getError() != null) {
                System.debug(response.getError());
            }
        }

        public void run() {
            Map<Object, Object> prevPaginatorParam = null;
            String pageAction = null;
            
            // handle pagination if we were invoked by a user clicking previous/next button
            if (actionParameters != null && actionParameters.get('paginator') != null) {
                prevPaginatorParam = (Map<Object, Object>) ((List<Object>) actionParameters.get(
                    'paginator'
                ))
                .iterator()
                .next();

                pageAction = context.getActionPayload().getName();
            }
            

            Map<String, Boolean> projectVisibilityByProjectKey = buildInitialProjectVisibilityMap();
            Map<String, Map<String, String>> projectsInfoMap = new Map<String, Map<String, String>>();

            populateMaps(projectsInfoMap, projectVisibilityByProjectKey, prevPaginatorParam, pageAction);

            publishHome(buildView(projectsInfoMap, projectVisibilityByProjectKey, prevPaginatorParam, pageAction));
        }
    }

    public static String buildDueStatusText(Date endDate) {
        return new DateStringHandler().buildDueStatusText(endDate);
    }
    public class DateStringHandler {
        private String getDueDateEmoji(Integer daysUntilDue) {
            if (daysUntilDue > 5) {
                return ':large_green_circle:';
            } else if (daysUntilDue >= 0) {
                return ':large_yellow_circle:';
            } else {
                return ':red_circle:';
            }
        }

        private String handlePluralDateUnit(Integer amt, String unit) {
            if (amt > 1) {
                return String.valueOf(amt) + ' ' + unit + 's';
            }
            return String.valueOf(amt) + ' ' + unit;
        }

        private String getDateDiffString(Integer days) {
            Integer daysDiff = Math.abs(days);
            if (days > 30) {
                Integer months = days / 30;
                return handlePluralDateUnit(months, 'month');
            }
            return handlePluralDateUnit(days, 'day');
        }

        private String getDueDateString(Integer daysUntilDue) {
            if (daysUntilDue > 0) {
                return ' Due in ' + getDateDiffString(daysUntilDue);
            }
            if (daysUntilDue == 0) {
                return 'Today';
            }
            return ' Due ' + getDateDiffString(-1 * daysUntilDue) + ' ago';
        }

        public String buildDueStatusText(Date endDate) {
            if (endDate == null) {
                return ' ';
            }
            Date today = DateTime.now().date();
            Integer daysUntilDue = today.daysBetween(endDate);

            return getDueDateEmoji(daysUntilDue) + ' ' + getDueDateString(daysUntilDue);
        }
    }
}