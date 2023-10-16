public with sharing class MTH_ProjectUtils {
    
    public static String getProjectUrl(PSA_Project__c project, Methodologies_Slack_App_Settings__c settings){
        String urlTemplate = '{0}/lightning/r/pse__Proj__c/{1}/view';
        List<Object> parameters = new List<Object>{settings.Org62_Base_URL__c,project.Org62_Id__c};
        return String.format(urlTemplate, parameters);
    }

    public static String getOpportunityDocumentsUrl(PSA_Project__c project, Methodologies_Slack_App_Settings__c settings){
        String urlTemplate = '{0}/lightning/r/Opportunity/{1}/related/AttachedContentDocuments/view';
        List<Object> parameters = new List<Object>{settings.Org62_Base_URL__c,project.Org62_Opportunity_Id__c};
        return String.format(urlTemplate, parameters);
    }

    public static String getProjectAssignmentsUrl(PSA_Project__c project, Methodologies_Slack_App_Settings__c settings){
        String urlTemplate = '{0}/lightning/r/pse__Proj__c/{1}/related/pse__Assignments__r/view';
        List<Object> parameters = new List<Object>{settings.Org62_Base_URL__c,project.Org62_Id__c};
        return String.format(urlTemplate, parameters);
    }
}