public with sharing class PSA_ProjectDataAccessor implements PSA_ProjectDAI {
    public PSA_Project__c[] getPSAProjectByProjectManagerUserId(Id userId) {
        return [
            SELECT Id, Name, End_Date__c
            FROM PSA_Project__c
            WHERE ProjectManagerUser__c = :userId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public PSA_Project__c[] getPSAProjectByProjectId(Set<Id> projectIds) {
        return [
            SELECT
                Id,
                Name,
                End_Date__c,
                Project_Manager__r.User_Record__c,
                Project_Manager__c,
                Project_ID__c,
                Engagement_Size__c,
                Engagement_Type__c,
                Targeted_Clouds_Used__c,
                Opportunity__r.Targeted_Clouds__c,
                Preferred_Methodology__c,
                Other_Preferred_Methodology__c,
                Project_Management_Tool__c,
                Other_Project_Management_Tool__c,
                Work_Management_Tool__c,
                Other_Work_Management_Tool__c,
                CICD_Tool__c,
                Other_CICD_Tool__c,
                Automated_Testing_Tool__c,
                Other_Automated_Testing_Tool__c,
                DAF_Review_Options__c,
                Org62_Id__c,
                Org62_Opportunity_Id__c,
                Org62_SOW_Link__c,
                Offering__c,
                SmartSheet_Link__c,
                Slack_Channel_ID__c,
                Start_Date__c,
                Billing_Type__c
            FROM PSA_Project__c
            WHERE Id = :projectIds
            WITH SECURITY_ENFORCED
        ];
    }

    public PSA_Project__c[] getProjectsAndMethodsFromProjectIds(
        Set<Id> projectIds,
        Id methodOwnerId
    ) {
        return [
            SELECT
                Id,
                Name,
                Start_Date__c,
                End_Date__c,
                Project_ID__c,
                Engagement_Size__c,
                Engagement_Type__c,
                Targeted_Clouds_Used__c,
                Opportunity__r.Targeted_Clouds__c,
                Preferred_Methodology__c,
                (
                    SELECT Id, Method__r.Name, Method__r.Method_Headline__c, End_Date__c, OwnerId
                    FROM Method_for_Projects__r
                    WHERE OwnerId = :methodOwnerId
                ),
                Other_Preferred_Methodology__c,
                Project_Management_Tool__c,
                Other_Project_Management_Tool__c,
                Work_Management_Tool__c,
                Other_Work_Management_Tool__c,
                CICD_Tool__c,
                Other_CICD_Tool__c,
                Automated_Testing_Tool__c,
                Other_Automated_Testing_Tool__c,
                DAF_Review_Options__c,
                Org62_Id__c
            FROM PSA_Project__c
            WHERE Id = :projectIds AND (NOT Name LIKE 'Z-%')
            WITH SECURITY_ENFORCED
            ORDER BY Id
        ];
    }

    public String getProjectsAndMethodsFromProjectIdsStringQuery(
        Set<Id> projectIds,
        Id methodOwnerId
    ) {
        List<String> projectIdsStr = (List<String>) new List<Id>(projectIds);
        String projectIdsCsv = '\'' + String.join(projectIdsStr, '\',\'') + '\'';
        return 'SELECT ' +
            'Id, ' +
            'Name, ' +
            'Start_Date__c, ' +
            'End_Date__c, ' +
            'Project_ID__c, ' +
            'Engagement_Size__c, ' +
            'Engagement_Type__c, ' +
            'Targeted_Clouds_Used__c, ' +
            'Opportunity__r.Targeted_Clouds__c, ' +
            'Preferred_Methodology__c, ' +
            '( ' +
            '    SELECT Id, Method__r.Name, Method__r.Method_Headline__c, End_Date__c, OwnerId ' +
            '    FROM Method_for_Projects__r ' +
            '    WHERE OwnerId = \'' +
            methodOwnerId +
            '\'' +
            ') ' +
            'Other_Preferred_Methodology__c, ' +
            'Project_Management_Tool__c, ' +
            'Other_Project_Management_Tool__c, ' +
            'Work_Management_Tool__c, ' +
            'Other_Work_Management_Tool__c, ' +
            'CICD_Tool__c, ' +
            'Other_CICD_Tool__c, ' +
            'Automated_Testing_Tool__c, ' +
            'Other_Automated_Testing_Tool__c, ' +
            'DAF_Review_Options__c, ' +
            'Org62_Id__c ' +
            'FROM PSA_Project__c ' +
            'WHERE Id IN (' +
            projectIdsCsv +
            ') AND (NOT Name LIKE \'Z-%\') ' +
            'WITH SECURITY_ENFORCED';
    }

    public String getProjectsAndMethodsCountFromProjectIdsStringQuery(Set<Id> projectIds) {
        List<String> projectIdsStr = (List<String>) new List<Id>(projectIds);
        String projectIdsCsv = '\'' + String.join(projectIdsStr, '\',\'') + '\'';
        return ('SELECT COUNT(Id) queryCount ' +
        'FROM PSA_Project__c ' +
        'WHERE Id IN (' +
        projectIdsCsv +
        ') AND (NOT Name LIKE \'Z-%\') ' +
        'WITH SECURITY_ENFORCED');
    }

    public PSA_Project__c[] getPSAProjectByProjectId(Id projectId) {
        return [
            SELECT Id, Name, End_Date__c
            FROM PSA_Project__c
            WHERE Id = :projectId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public PSA_Project__c[] getPSAProjectAndOpportunityByProjectId(Set<Id> projectIds) {
        return [
            SELECT
                Id,
                Name,
                End_Date__c,
                Project_ID__c,
                Engagement_Size__c,
                Engagement_Type__c,
                Targeted_Clouds_Used__c,
                Project_Setup_Status__c,
                Preferred_Methodology__c,
                Other_Preferred_Methodology__c,
                Project_Management_Tool__c,
                Other_Project_Management_Tool__c,
                Work_Management_Tool__c,
                Other_Work_Management_Tool__c,
                CICD_Tool__c,
                Other_CICD_Tool__c,
                Automated_Testing_Tool__c,
                Other_Automated_Testing_Tool__c,
                DAF_Review_Options__c,
                Org62_Id__c,
                Org62_Opportunity_Id__c,
                Org62_SOW_Link__c,
                Offering__c,
                SmartSheet_Link__c,
                Slack_Channel_ID__c,
                Start_Date__c,
                Billing_Type__c,
                Bookings__c,
                Opportunity__r.Targeted_Clouds__c,
                Opportunity__r.Name
            FROM PSA_Project__c
            WHERE Id = :projectIds
            WITH SECURITY_ENFORCED
        ];
    }

    public List<String> getPSAProjectTargetedCloudsUsed(String projectId) {
        List<String> targetedCloudsUsed = new List<String>();
        PSA_Project__c selectedProject;
        try {
            selectedProject = [SELECT Id, Name, Targeted_Clouds_Used__c, Opportunity__r.Targeted_Clouds__c FROM PSA_Project__c WHERE Id = :projectId];
        }
        catch (Exception e){
            return targetedCloudsUsed;
        }
        if (String.isBlank(selectedProject.Targeted_Clouds_Used__c) && !String.isBlank(selectedProject.Opportunity__r.Targeted_Clouds__c)){
            targetedCloudsUsed = selectedProject.Opportunity__r.Targeted_Clouds__c.split(';');
            return targetedCloudsUsed;
        }
        if (!String.isBlank(selectedProject.Targeted_Clouds_Used__c)){
            targetedCloudsUsed = selectedProject.Targeted_Clouds_Used__c.split(';');
            return targetedCloudsUsed;
        }
        return targetedCloudsUsed;
    }

    public List<Slack.Option> getPSAProjectPicklistOptions(String fieldName) {
        List<Slack.Option> pickListOptions = new List<Slack.Option>();
        Schema.DescribeFieldResult fieldResult;
        switch on fieldName {
            when 'Engagement_Size__c' {
                fieldResult = PSA_Project__c.Engagement_Size__c.getDescribe();
            }
            when 'Preferred_Methodology__c' {
                fieldResult = PSA_Project__c.Preferred_Methodology__c.getDescribe();
            }
            when 'Engagement_Type__c' {
                fieldResult = PSA_Project__c.Engagement_Type__c.getDescribe();
            }
            when 'Project_Management_Tool__c' {
                fieldResult = PSA_Project__c.Project_Management_Tool__c.getDescribe();
            }
            when 'Work_Management_Tool__c' {
                fieldResult = PSA_Project__c.Work_Management_Tool__c.getDescribe();
            }
            when 'CICD_Tool__c' {
                fieldResult = PSA_Project__c.CICD_Tool__c.getDescribe();
            }
            when 'Automated_Testing_Tool__c' {
                fieldResult = PSA_Project__c.Automated_Testing_Tool__c.getDescribe();
            }
            when 'DAF_Review_Options__c' {
                fieldResult = PSA_Project__c.DAF_Review_Options__c.getDescribe();
            }
            when 'Opportunity__r.Targeted_Clouds__c' {
                fieldResult = Opportunity.Targeted_Clouds__c.getDescribe();
            }
            when 'Offering__c' {
                fieldResult = PSA_Project__c.Offering__c.getDescribe();
            }
        }
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : pickListValues) {
            String pickListLabel = pickListVal.getLabel();
            Slack.Option option = new Slack.Option(pickListLabel, pickListLabel);
            pickListOptions.add(option);
        }
        return pickListOptions;
    }

    public PSA_Project__c updateProjectFields(Id projectId, Map<String, Object> formData) {
        PSA_Project__c[] projects = this.getPSAProjectByProjectId(new Set<Id>{ projectId });
        PSA_Project__c projectToUpdate = projects[0];

        // TODO: Refactor to a loop
        if (formData.containsKey('engagement_type_select')) {
            projectToUpdate.Engagement_Type__c = String.valueOf(
                formData.get('engagement_type_select')
            );
        }

        if (formData.containsKey('offering_select')) {
            projectToUpdate.Offering__c = String.valueOf(
                formData.get('offering_select')
            );
        }

        if (formData.containsKey('verify_engagement_sizing_select')) {
            projectToUpdate.Engagement_Size__c = String.valueOf(
                formData.get('verify_engagement_sizing_select')
            );
        }

        if (formData.containsKey('targeted_clouds_select')) {
            String targetedCloudsStr = '';
            Object targetedClouds = formData.get('targeted_clouds_select');
            if (targetedClouds instanceof List<Object>) {
                targetedCloudsStr = String.join((List<Object>)(targetedClouds), ';');
            }
            projectToUpdate.Targeted_Clouds_Used__c = targetedCloudsStr;
        }

        if (formData.containsKey('customer_methodology_select')) {
            projectToUpdate.Preferred_Methodology__c = String.valueOf(
                formData.get('customer_methodology_select')
            );
        }

        if (formData.containsKey('other_methodology_used')) {
            projectToUpdate.Other_Preferred_Methodology__c = String.valueOf(
                formData.get('other_methodology_used')
            );
        }

        if (formData.containsKey('project_management_tool_select')) {
            projectToUpdate.Project_Management_Tool__c = String.valueOf(
                formData.get('project_management_tool_select')
            );
        }

        if (formData.containsKey('other_project_management_tool')) {
            projectToUpdate.Other_Project_Management_Tool__c = String.valueOf(
                formData.get('other_project_management_tool')
            );
        }

        if (formData.containsKey('work_management_tool_select')) {
            projectToUpdate.Work_Management_Tool__c = String.valueOf(
                formData.get('work_management_tool_select')
            );
        }

        if (formData.containsKey('other_work_management_tool')) {
            projectToUpdate.Other_Work_Management_Tool__c = String.valueOf(
                formData.get('other_work_management_tool')
            );
        }

        if (formData.containsKey('cicd_tool_select')) {
            projectToUpdate.CICD_Tool__c = String.valueOf(
                formData.get('cicd_tool_select')
            );
        }

        if (formData.containsKey('other_cicd_tool')) {
            projectToUpdate.Other_CICD_Tool__c = String.valueOf(
                formData.get('other_cicd_tool')
            );
        }

        if (formData.containsKey('automated_testing_tool_select')) {
            projectToUpdate.Automated_Testing_Tool__c = String.valueOf(
                formData.get('automated_testing_tool_select')
            );
        }

        if (formData.containsKey('other_automated_testing_tool')) {
            projectToUpdate.Other_Automated_Testing_Tool__c = String.valueOf(
                formData.get('other_automated_testing_tool')
            );
        }

        if (formData.containsKey('daf_review_options_select')) {
            projectToUpdate.DAF_Review_Options__c = String.valueOf(
                formData.get('daf_review_options_select')
            );
        }

        if (formData.containsKey('org62_sow_link')) {
            projectToUpdate.Org62_SOW_Link__c = String.valueOf(
                formData.get('org62_sow_link')
            );
        }

        if (formData.containsKey('channel_id')) {
            projectToUpdate.Slack_Channel_ID__c = String.valueOf(formData.get('channel_id'));
        }

        update projectToUpdate;
        return projectToUpdate;
    }

    public List<PSA_Project__c> updateProjects(List<PSA_Project__c> projectsToUpdate) {
        if (projectsToUpdate?.isEmpty() == false) {
            update projectsToUpdate;
        }
        return projectsToUpdate;
    }
}