public with sharing class MTH_ManageProjectViewOpen {
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static MethodByGroupingDAI methodByGroupingDA = new MethodByGroupingDataAccessor();
    @testVisible
    private static UserDAI userDA = new UserDataAccessor();
    @testVisible
    private static MTH_Pagination paginator = new MTH_Pagination();

    private static ProjectAssignmentDAI projectAssignmentDA = new ProjectAssignmentDataAccessor();

    private static Set<Id> userIdsToUpdateSlackId = new Set<Id>();

    public static void buildHomeView(Id projectId, String teamId, String slackId) {
        buildHomeView(projectId, teamId, slackId, paginator.NEXT_PAGE, 0, null);
    }

    @future(callout=true)
    public static void buildHomeView(
        Id projectId,
        String teamId,
        String slackId,
        String pageAction,
        Integer prevPaginatorPage,
        Integer prevTotalPages
    ) {
        Slack.App app = Slack.App.Methodologies.get();
        Slack.BotClient botClient = app.getBotClientForTeam(teamId);
        Slack.ViewReference viewReference = Slack.View.mth_manage_project.get();
        PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{ projectId });

        Integer currPage = (prevPaginatorPage == null)? 0 : prevPaginatorPage;
        List<Map<String, Object>> methodsList = getMethods(projects[0].Id, currPage, pageAction);
        viewReference.setParameter('project', createProjectMap(projects[0]));
        viewReference.setParameter('methods', methodsList);
        Boolean isUserProjectManager = isUserProjectManager(projectId);

        viewReference.setParameter('visibleToProjectManagerOnly', isUserProjectManager);
        viewReference.setParameter('visibleToNonProjectManager', !isUserProjectManager);
        // handle pagination
        String query = methodsDA.getMethodsByPSAProjectIdStringQuery(projects[0].Id);
        String orderBy = 'Method__r.Name';

        if (pageAction == null || pageAction == paginator.NEXT_PAGE) {
            currPage += 1;
        } else {
            currPage -= 1;
        }
        
        Boolean hasNextPage = paginator.hasNextPage(query, orderBy, currPage);
        Boolean hasPreviousPage = paginator.hasPreviousPage(query, orderBy, currPage);
        Integer totalPages = prevTotalPages;

        if (prevTotalPages == null) {
            totalPages = paginator.totalPages(
                methodsDA.getMethodsCountByPSAProjectIdStringQuery(projects[0].Id)
            );
        }

        List<Map<String, String>> paginatorParam = paginator.generatePaginatorViewParam(
            hasNextPage,
            hasPreviousPage,
            currPage,
            totalPages
        );

        viewReference.setParameter('paginator', paginatorParam);

        Slack.HomeView homeView = new Slack.HomeView.builder().viewReference(viewReference).build();

        Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder()
            .userId(slackId)
            .view(homeView)
            .build();

        Slack.ViewsPublishResponse response = botClient.viewsPublish(req);

        if (response.getError() != null) {
            System.debug(response.getError());
        }
        if (!userIdsToUpdateSlackId.isEmpty()) {
            System.enqueueJob(new MTH_UpdateUsersWithSlackUserId(userIdsToUpdateSlackId));
        }
    }


    private static List<Map<String, Object>> getMethods(Id projectId, Integer currPage, String pageAction) {
        String query = methodsDA.getMethodsByPSAProjectIdStringQuery(projectId);
        String orderBy = 'Method__r.Name';
        Methods__c[] methods = null;
        
        if (pageAction == null || pageAction == paginator.NEXT_PAGE) {
            Map<Integer, List<SObject>> methodsByPage = paginator.getNextPage(
                query,
                orderBy,
                currPage
            );

            methods = (Methods__c[])methodsByPage.get(currPage + 1);
        } else {
            Map<Integer, List<SObject>> methodsByPage = paginator.getPreviousPage(
                query,
                orderBy,
                currPage
            );

            methods = (Methods__c[])methodsByPage.get(currPage - 1);
        }

        Set<Id> methodIds = new Set<Id>();
        for (Methods__c method : methods) {
            methodIds.add(method.Method__c);
        }

        Method_by_Grouping__c[] methodByGroupings = methodByGroupingDA.getMethodByGroupingByMethodId(
            methodIds
        );

        Map<Id, String> methodByGroupingMap = new Map<Id, String>();
        for (Method_by_Grouping__c methodByGrouping : methodByGroupings) {
            methodByGroupingMap.put(methodByGrouping.Method__c, methodByGrouping.Grouping__r.Name);
        }
        setSlackUserIds(methods);
        return getMethodsMapList(methods, methodByGroupingMap, projectId);
    }

    private static Map<Id, User> getUsers(List<Methods__c> methods) {
        Map<Id, User> usersById = new Map<Id, User>(); //using a map to prevent duplicate users
        for (Methods__c m : methods) {
            User u = m.Assigned_Resource__r;
            if (u != null && String.isBlank(u.Slack_User_Id__c)) {
                usersById.put(u.Id, u);
            }
        }
        return usersById;
    }
    private static void setSlackUserIds(List<Methods__c> methods) {
        Map<Id, User> usersFromMethods = getUsers(methods);
        if (usersFromMethods.isEmpty()) {
            return;
        }
        for (User u : usersFromMethods.values()) {
            MTH_SlackUserIdHandler.getSlackUserIdFromSFUser(u);
        }
        userIdsToUpdateSlackId = usersFromMethods.keySet();
    }

    private static List<Map<String, Object>> getMethodsMapList(
        Methods__c[] methods,
        Map<Id, String> methodByGroupingMap,
        Id projectId
    ) {
        List<Map<String, Object>> methodsList = new List<Map<String, Object>>();

        for (Methods__c method : methods) {
            Boolean hasNoOwner = false;
            if (method.Assigned_Resource__r.Slack_User_Id__c == '') {
                hasNoOwner = true;
            }

            String ownerStr = getOwnerString(method.Assigned_Resource__r.Slack_User_Id__c);
            String assignedUserString = '';
            if (hasNoOwner || ownerStr.equals('')) {
                assignedUserString = '_No assignment set_';
            } else {
                assignedUserString = 'Assigned user ' + ownerStr;    
                if (String.isNotBlank(method.Assigned_Resource__r.CSG_Role__c)) {
                    assignedUserString += ' (' + method.Assigned_Resource__r.CSG_Role__c + ')';
                }
            }

            methodsList.add(
                new Map<String, Object>{
                    'Name' => method.Method__r.Name,
                    'MethodId' => method.Method__c,
                    'Id' => String.valueOf(method.Id),
                    'CompletionStatus' => getCompletionStatus(method),
                    'Owner' => getOwnerString(method.Assigned_Resource__r.Slack_User_Id__c),
                    'hasNoOwner' => hasNoOwner,
                    'Subline' => getSublineString(method.Task_Title__c, methodByGroupingMap.get(method.Method__c), method.Completion_Status__c == 'Complete'),
                    'assignedResource' => method.Assigned_Resource__c,
                    'assignedUserString' => assignedUserString,
                    'projectAssignments' => MTH_UserSelectModalHandler.getProjectAssignmentUserOptionsByProjectId(projectId),
                    'overflowOptions' => getOverflowMenuOptionsForMethods(method)
                }
            );
        }
        return methodsList;
    }

    private static List<Slack.Option> getOverflowMenuOptionsForMethods(Methods__c method) {
        List<Slack.Option> overflowOptions = new List<Slack.Option>();
        overflowOptions.add(new Slack.Option('View Details', 'view-details-' + method.Id));
        overflowOptions.add(new Slack.Option('Assign Method', 'assign-method-' + method.Id));

        if (method.Completion_Status__c != 'Complete') {
            overflowOptions.add(
                new Slack.Option('Change Date', 'change-date-' + method.Id)
            );
            overflowOptions.add(
                new Slack.Option('Complete Method', 'complete-method-' + method.Id)
            );
        }

        return overflowOptions;
    }

    private static Map<String, String> createProjectMap(PSA_Project__c psaProject) {
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Name', psaProject.Name);
        projectMap.put('Id', psaProject.Id);
        return projectMap;
    }

    private static String getCompletionStatus(Methods__c method) {
        //ignoring the case of having Actual_Start_Date__c in the future as this shouldn't happen.
        if (method.Completion_Status__c == 'Complete') {
            return ':white_check_mark: _Complete_';
        } else if(method.Actual_Start_Date__c?.daysBetween(Date.today()) >= 0){
            return '_In progress, started ' + method.Actual_Start_Date__c.format() + '_';
        } else if (method.Start_Date__c == null && method.Actual_Start_Date__c == null) {
            return '_No start date set_';
        } else if (method.Start_Date__c?.daysBetween(Date.today()) < 0) {
            return '_Start ' + method.Start_Date__c.format() + '_';
        } else {
            return ':red_circle: _Start overdue ' + method.Start_Date__c.format() + '_';
        }
    }

    private static String getSublineString(String taskTitle, String grouping, Boolean complete){
        String[] results = new String[]{};
        if (taskTitle != null) {
            results.add('_' + taskTitle + '_');
        }
        if (grouping != null) {
            results.add('_' + grouping + '_');
        }
        if (complete) {
            results.add(':white_check_mark: _Complete_');
        }
        return String.join(results, ' • ');
    }

    private static String getOwnerString(String ownerSlackId) {
        if (ownerSlackId == null) {
            return '';
        }
        return '_*<@' + ownerSlackId + '>*_ ';
    }

    private static Boolean isUserProjectManager(Id projectId) {

        Id userId = UserInfo.getUserId();

        Project_Assignment__c[] projectAssignments = projectAssignmentDA.getProjectAssignmentsByProjectId(
            new Set<Id>{ projectId }
        );

        for (Project_Assignment__c assignment : projectAssignments) {
            System.debug('*** Comparing assignment '+assignment.Resource__r.User_Record__c+' vs '+userId);
            if (assignment.Project_Role__c == null){
                continue;
            }
            if (String.valueOf(assignment?.Project_Role__c)?.contains('Project Manager') && assignment.Resource__r.User_Record__c == userId) {
                return true;
            }
        }
        return false;
    }
}