public with sharing class MTH_ProjectSetupModalOpen {
    @testVisible
    private static PSA_ProjectDAI psaProjectDA = new PSA_ProjectDataAccessor();
    @testVisible
    private static ProjectProductDAI projectProductDA = new ProjectProductDataAccessor();

    public static Slack.ModalView openModal(Id projectId) {
        Slack.ViewReference viewReference = Slack.View.mth_proj_setup_start_modal.get();
        PSA_Project__c[] projects = psaProjectDA.getPSAProjectAndOpportunityByProjectId(new Set<Id>{projectId});
        PSA_Project__c project = projects[0];
        
        Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();

        try {
            markProjectSetupInProgress(project);
        } catch (Exception e) {
            return MTH_ErrorModalOpen.openModal('Looks like this project might not be configured correctly, please contact Ops for assistance');
        }
        
        Map<String, String> projectMap = createProjectMap(project, settings);
        
        viewReference.setParameter('project', projectMap);
        viewReference.setParameter('textInputVisibility', getTextInputVisibility(projectMap));

        return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    private static Map<String, Boolean> getTextInputVisibility(Map<String, String> projectMap) {
        String methodology = projectMap.get('Preferred_Methodology__c');
        String engagementSizing = projectMap.get('Engagement_Size__c');
        
        Map<String, Boolean> textInputVisibility = new Map<String, Boolean>{
          'engagementSizing' => engagementSizing != null ,
          'methodologyUsed' => methodology != null
        };
  
        return textInputVisibility;
    }

    private static void markProjectSetupInProgress(PSA_Project__c project){
        if (project.Project_Setup_Status__c == 'Not Started' || String.isBlank(project.Project_Setup_Status__c)) {
            project.Project_Setup_Status__c = 'In Progress';
            psaProjectDA.updateProjects(new List<PSA_Project__c>{project});
        }
    }

    // IMPORTANT: if you do any changes to the mapping here, make sure it's also reflected in MTH_ProjectSetupSelectHandler.buildProjectMap
    // TODO: consider refactoring to one mapping method
    private static Map<String, String> createProjectMap(PSA_Project__c project, Methodologies_Slack_App_Settings__c settings){
        Map<String, String> projectMap = new Map<String, String>();
        projectMap.put('Name', String.valueOf(project.Name));
        projectMap.put('Id', project.Id);

        projectMap.put('Engagement_Size__c', project.Engagement_Size__c);
        projectMap.put('Offering__c', project.Offering__c);
        projectMap.put('Engagement_Type__c', project.Engagement_Type__c);
        
        projectMap.put('Preferred_Methodology__c', project.Preferred_Methodology__c);

        projectMap.put('Project_Management_Tool__c', project.Project_Management_Tool__c);        

        projectMap.put('Work_Management_Tool__c', project.Work_Management_Tool__c);

        projectMap.put('CICD_Tool__c', project.CICD_Tool__c);

        projectMap.put('Automated_Testing_Tool__c', project.Automated_Testing_Tool__c);

        projectMap.put('DAF_Review_Options__c', project.DAF_Review_Options__c);
        projectMap.put('url', MTH_ProjectUtils.getProjectUrl(project, settings));
        
        if (String.isNotBlank(String.valueOf(project.Bookings__c))){
            projectMap.put('Bookings__c', String.valueOf((project.Bookings__c).format()));
        }
        
        return projectMap;
    }
}