public with sharing class MTH_ProjectSetupNext extends Slack.ActionDispatcher {
    @testVisible
    private static MethodsDAI methodsDA = new MethodsDataAccessor();
    @testVisible
    private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
    private static MTH_Pagination paginator = new MTH_Pagination();

    @testVisible
    private static MTH_SlackChannelSetupInterace channelSetup = new MTH_SlackChannelSetup();

    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        String setupStep = String.valueOf(parameters.get('setupStep'));
        if (setupStep.equals('1') && displayProjectSetupDetailsView(context.getFormData())) {
            return Slack.ActionHandler.pushModal(new Handler(parameters, context));
        } else if (setupStep.equals('3')) {
            return Slack.ActionHandler.pushModal(new Handler(parameters, context));
        } else {
            return Slack.ActionHandler.updateModal(new Handler(parameters, context));
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
            Map<String, Object> formData = context.getFormData();
            String setupStep = String.valueOf(parameters.get('setupStep'));
            Id projectId = (Id) parameters.get('projectId');
            PSA_Project__c[] projects = projectDA.getPSAProjectAndOpportunityByProjectId(
                new Set<Id>{ projectId }
            );
            PSA_Project__c project = projects[0];
            Slack.ViewReference viewReference = this.getNextModalView(
                setupStep,
                formData,
                project,
                parameters
            );

            Slack.ModalView modalView = new Slack.ModalView.Builder()
                .viewReference(viewReference)
                .clearOnClose(setupStep.equals('4'))
                .build();

            return modalView;
        }

        @testVisible
        private Slack.ViewReference getNextModalView(
            String setupStep,
            Map<String, Object> formData,
            PSA_Project__c project,
            Map<String, Object> parameters
        ) {
            Slack.ViewReference viewReference;
            Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
            switch on setupStep {
                when '1' {
                    Map<String, Object> updatedFormData = getDetailClearingFormData(formData);
                    projectDA.updateProjectFields(project.Id, updatedFormData);
                    if (displayProjectSetupDetailsView(context.getFormData())) {
                        viewReference = getProjectDetailsSetupView(project, settings, formData);
                    } else {
                        viewReference = getSowProjectSetupView(project, settings);
                    }
                }
                when '1.5' {
                    projectDA.updateProjectFields(project.Id, formData);
                    viewReference = getSowProjectSetupView(project, settings);
                }
                when '2' {
                    projectDA.updateProjectFields(project.Id, formData);
                    viewReference = getProjectSetupStepThreeViewReference(project.Id);
                }
                when '3' {
                    viewReference = getSlackProjectSetupView(project, settings, null, null);
                }
                when '4' {
                    try {
                        Boolean generateChannelNameSuffix = Boolean.valueOf(
                            parameters.get('showChannelErrorMessage')
                        );
                        String channelId = finalizeSlackSetup(
                            project,
                            formData,
                            context.getUserId(),
                            context.getTeamId(),
                            generateChannelNameSuffix
                        );
                        updateProjectSetupStatus(
                            project,
                            Label.Project_Status_Project_Parameters_Set
                        );
                        viewReference = Slack.View.mth_setup_finished_modal.get();
                        viewReference.setParameter('teamId', settings.Team_Id__c);
                        viewReference.setParameter('appId', settings.App_Id__c);
                        viewReference.setParameter('userId', context.getUserId());
                        viewReference.setParameter('channelId', channelId);
                    } catch (MTH_SlackApiErrors.ChannelCreateException e) {
                        viewReference = getSlackProjectSetupView(
                            project,
                            settings,
                            e.getChannelName(),
                            formData
                        );
                    }
                }
                when null {
                    throw new NoSetupStepProvidedException('No setup step provided');
                }
                when else {
                    throw new UnrecognizedSetupStepException('Unrecognized setup step');
                }
            }

            return viewReference;
        }
    }

    private static Boolean displayProjectSetupDetailsView(Map<String, Object> formData) {
        Map<String, Boolean> textInputVisibility = getTextInputVisibility(formData);
        for (String key : textInputVisibility.keySet()) {
            if (textInputVisibility.get(key)) {
                return true;
            }
        }
        return false;
    }

    private static Slack.ViewReference getProjectDetailsSetupView(
        PSA_Project__c project,
        Methodologies_Slack_App_Settings__c settings,
        Map<String, Object> formData
    ) {
        Map<String, Boolean> textInputVisibility = getTextInputVisibility(formData);

        Map<String, String> projectMap = new Map<String, String>{
            'Id' => project.Id,
            'Name' => project.Name,
            'Other_Preferred_Methodology__c' => project.Preferred_Methodology__c,
            'Other_Project_Management_Tool__c' => project.Other_Project_Management_Tool__c,
            'Other_Work_Management_Tool__c' => project.Other_Work_Management_Tool__c,
            'Other_CICD_Tool__c' => project.Other_CICD_Tool__c,
            'Other_Automated_Testing_Tool__c' => project.Other_Automated_Testing_Tool__c,
            'url' => MTH_ProjectUtils.getProjectUrl(project, settings)
        };
        Slack.ViewReference viewReference = Slack.View.mth_proj_setup_start_details_modal.get();
        viewReference.setParameter('textInputVisibility', textInputVisibility);
        viewReference.setParameter('project', projectMap);
        return viewReference;
    }

    private static Map<String, Object> getDetailClearingFormData(Map<String, Object> formData){
        Map<String, Object> updatedFormData = formData.clone();
        Map<String, Boolean> detailFieldsVisibility = getTextInputVisibility(formData);
        Map<String, String> visibilityToFormDataValuesMap = new Map<String, String>{
            'showOtherMethodologyUsed' => 'other_methodology_used',
            'showOtherProjectManagement' => 'other_project_management_tool',
            'showOtherWorkManagement' => 'other_work_management_tool',
            'showOtherCICD' => 'other_cicd_tool',
            'showOtherAutomatedTesting' => 'other_automated_testing_tool'
        };

        for (String key : detailFieldsVisibility.keySet()) {
            
            if (detailFieldsVisibility.get(key) || !visibilityToFormDataValuesMap.containsKey(key)){
                continue;
            }

            updatedFormData.put(visibilityToFormDataValuesMap.get(key), null);
        }
        return updatedFormData;
    }

    private static Map<String, Boolean> getTextInputVisibility(Map<String, Object> formData) {
        String methodology = (String) formData.get('customer_methodology_select');
        String projectManagement = (String) formData.get('project_management_tool_select');
        String workManagement = (String) formData.get('work_management_tool_select');
        String cicd = (String) formData.get('cicd_tool_select');
        String automatedTesting = (String) formData.get('automated_testing_tool_select');

        Map<String, Boolean> textInputVisibility = new Map<String, Boolean>{
            'showOtherMethodologyUsed' => methodology != null && methodology.startsWith('Other'),
            'showOtherProjectManagement' => projectManagement != null &&
            projectManagement.startsWith('Other'),
            'showOtherWorkManagement' => workManagement != null &&
            workManagement.startsWith('Other'),
            'showOtherCICD' => cicd != null && cicd.startsWith('Other'),
            'showOtherAutomatedTesting' => automatedTesting != null &&
            automatedTesting.startsWith('Other')
        };
        return textInputVisibility;
    }

    private static Slack.ViewReference getSowProjectSetupView(
        PSA_Project__c project,
        Methodologies_Slack_App_Settings__c settings
    ) {
        Slack.ViewReference viewReference = Slack.View.mth_proj_setup_sow_modal.get();
        viewReference.setParameter('projectTitle', project.Name);
        viewReference.setParameter('projectId', project.Id);
        viewReference.setParameter('projectUrl', MTH_ProjectUtils.getProjectUrl(project, settings));
        viewReference.setParameter('documentsUrl', MTH_ProjectUtils.getOpportunityDocumentsUrl(project, settings));
        viewReference.setParameter('assignmentsUrl', MTH_ProjectUtils.getProjectAssignmentsUrl(project, settings));
        viewReference.setParameter('org62SowLink', project.Org62_SOW_Link__c);

        return viewReference;
    }

    private static Slack.ViewReference getSlackProjectSetupView(
        PSA_Project__c project,
        Methodologies_Slack_App_Settings__c settings,
        String channelNameError,
        Map<String, Object> prevAttemptFormData
    ) {
        Slack.ViewReference viewReference = Slack.View.mth_proj_setup_slack_modal.get();
        viewReference.setParameter('projectName', project.Name);
        viewReference.setParameter('projectId', project.Id);
        viewReference.setParameter('projectUrl', MTH_ProjectUtils.getProjectUrl(project, settings));
        viewReference.setParameter('channelId', project.Slack_Channel_ID__c);
        if (prevAttemptFormData != null) {
            viewReference.setParameter(
                'accountChannelId',
                String.valueOf(prevAttemptFormData.get('account_channel_id'))
            );
            viewReference.setParameter(
                'spwLink',
                String.valueOf(prevAttemptFormData.get('spw_link'))
            );
        }
        viewReference.setParameter('showEditChannel', String.isBlank(project.Slack_Channel_ID__c));
        viewReference.setParameter('hideEditChannel', !String.isBlank(project.Slack_Channel_ID__c));
        viewReference.setParameter(
            'showChannelHint',
            String.isBlank(channelNameError) && String.isBlank(project.Slack_Channel_ID__c)
        );
        viewReference.setParameter('showChannelErrorMessage', !String.isBlank(channelNameError));
        viewReference.setParameter('channelNameError', channelNameError);
        return viewReference;
    }

    private static void updateProjectSetupStatus(PSA_Project__c project, String status) {
        project.Project_Setup_Status__c = status;
        projectDA.updateProjects(new List<PSA_Project__c>{ project });
    }

    private static String finalizeSlackSetup(
        PSA_Project__c project,
        Map<String, Object> formData,
        String userId,
        String teamId,
        Boolean generateChannelNameSuffix
    ) {
        String channelId = project.Slack_Channel_ID__c;
        String accountChannelId = null;
        String swpLink = null;

        if (formData != null) {
            channelId = String.valueOf(formData.get('channel_id'));
            accountChannelId = String.valueOf(formData.get('account_channel_id'));
            swpLink = String.valueOf(formData.get('spw_link'));
        }

        if (String.isBlank(channelId)) {
            try {
                channelId = channelSetup.initChannel(
                    project,
                    teamId,
                    userId,
                    generateChannelNameSuffix
                );
            } catch (MTH_SlackApiErrors.ChannelCreateException e) {
                // TODO: handle exception here and display another view
                throw e;
            }
        }

        if (String.isBlank(project.Slack_Channel_ID__c)) {
            channelSetup.postProjectKTData(
                project,
                channelId,
                swpLink,
                accountChannelId,
                teamId,
                userId
            );
        }

        Map<String, Object> fieldsToUpdate = new Map<String, Object>{ 'channel_id' => channelId };
        projectDA.updateProjectFields(project.Id, fieldsToUpdate);
        return channelId;
    }

    public static List<Map<String, Object>> createMethodsMapList(
        String engagementSize,
        List<SObject> methodsList
    ) {
        List<Map<String, Object>> methodsMapList = new List<Map<String, Object>>();
        for (Methods__c methods : (Methods__c[]) methodsList) {
            Map<String, Object> methodsMap = new Map<String, Object>();
            methodsMap.put('Id', (Id) methods.Id);
            methodsMap.put('MethodId', methods.Method__r.Id);
            methodsMap.put('MethodName', methods.Method__r.Name);
            methodsMap.put('Method_in_SOW__c', methods.Method_in_SOW__c);
            methodsMap.put(
                'EngagementSize',
                getMethodEngagementSizeByProject(engagementSize, methods.Method__r)
            );

            // overflow options have View and Delete and ability to Mark or Unmark the method as a SOW deliverable
            List<Slack.Option> overflowOptions = new List<Slack.Option>{
                new Slack.Option('View', 'view-details-' + methods.Id),
                new Slack.Option('Delete', 'delete-' + methods.Id)
            };
            if (methods.Method_in_SOW__c) {
                overflowOptions.add(
                    new Slack.Option('Unmark as Deliverable', 'unmark-deliverable-' + methods.Id)
                );
            } else {
                overflowOptions.add(
                    new Slack.Option('Mark as Deliverable', 'mark-deliverable-' + methods.Id)
                );
            }

            methodsMap.put('OverflowOptions', overflowOptions);
            methodsMapList.add(methodsMap);
        }
        return methodsMapList;
    }

    public static Slack.ViewReference getProjectSetupStepThreeViewReference(Id projectId) {
        PSA_Project__c[] projects = projectDA.getPSAProjectByProjectId(new Set<Id>{ projectId });
        PSA_Project__c project = projects[0];

        String query = methodsDA.getMethodsByPSAProjectIdStringQuery((String) project.Id);
        String orderBy = 'Method__r.Name';

        Map<Integer, List<SObject>> methodsForProject = paginator.getNextPage(query, orderBy, 0);
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

        Slack.ViewReference viewReference = Slack.View.mth_proj_setup_mthd_manage_modal.get();
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
        viewReference.setParameter('projectUrl', MTH_ProjectUtils.getProjectUrl(project, settings));
        viewReference.setParameter('projectTitle', project.Name);
        viewReference.setParameter('projectId', project.Id);
        viewReference.setParameter(
            'methods',
            createMethodsMapList(project.Engagement_Size__c, methodsForProject.get(1))
        );
        viewReference.setParameter('paginator', paginatorParam);
        viewReference.setParameter('engagementSize', project.Engagement_Size__c);

        viewReference.setParameter('org62SowLink', project.Org62_SOW_Link__c);
        viewReference.setParameter('org62OpportunityId', project.Org62_Opportunity_Id__c);

        return viewReference;
    }

    private static String getMethodEngagementSizeByProject(
        String engagementSize,
        Method__c method
    ) {
        switch on engagementSize {
            when 'Micro' {
                return method?.Micro__c;
            }
            when 'Small' {
                return method?.Small__c;
            }
            when 'Medium' {
                return method?.Medium__c;
            }
            when 'Large' {
                return method?.Large__c;
            }
            when 'Program' {
                return method?.Program__c;
            }
            when else {
                return method?.Tier_1__c;
            }
        }
    }

    public class NoSetupStepProvidedException extends Exception {
    }
    public class UnrecognizedSetupStepException extends Exception {
    }
}