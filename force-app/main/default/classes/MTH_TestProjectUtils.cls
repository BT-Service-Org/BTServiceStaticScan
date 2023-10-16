@isTest
public with sharing class MTH_TestProjectUtils {

    private static PSA_Project__c project;
    private static Methodologies_Slack_App_Settings__c settings;

    static void makeData(){
        project = new PSA_Project__c(
            Id = 'a393C000000A9WCQA0',
            Org62_Id__c = 'org-62-id',
            Org62_Opportunity_Id__c = 'opp-org-62-id'
        );

        settings = new Methodologies_Slack_App_Settings__c(
            Services_Org_URL__c = 'sc-url',
            Org62_Base_URL__c = 'https://org62.com'
        );
    }

    @isTest
    private static void projectUrl_isValidFormat() {
        makeData();
        String actual = MTH_ProjectUtils.getProjectUrl(project, settings);
        System.assertEquals('https://org62.com/lightning/r/pse__Proj__c/org-62-id/view', actual);
    }

    @isTest
    private static void opportunityDocumentUrl_isValidFormat() {
        makeData();
        String actual = MTH_ProjectUtils.getOpportunityDocumentsUrl(project, settings);
        System.assertEquals('https://org62.com/lightning/r/Opportunity/opp-org-62-id/related/AttachedContentDocuments/view', actual);
    }

    @isTest
    private static void projectAssignmentUrl_isValidFormat() {
        makeData();
        String actual = MTH_ProjectUtils.getProjectAssignmentsUrl(project, settings);
        System.assertEquals('https://org62.com/lightning/r/pse__Proj__c/org-62-id/related/pse__Assignments__r/view', actual);
    }
}