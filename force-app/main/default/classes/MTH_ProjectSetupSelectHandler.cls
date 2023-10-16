/**
 * @description Handles dropdown selection changes in mth_proj_setup_start_modal.view.
 */
public with sharing class MTH_ProjectSetupSelectHandler extends Slack.ActionDispatcher {
  @testVisible
  private static PSA_ProjectDAI projectDA = new PSA_ProjectDataAccessor();
  @testVisible
  private static ProjectProductDAI projectProductDA = new ProjectProductDataAccessor();

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
      Id projectId = (Id) parameters.get('projectId');
      Slack.ActionPayload actionPayload = context.getActionPayload();
      Map<String, Object> formData = context.getFormData();

      Slack.ViewReference viewReference = Slack.View.mth_proj_setup_start_modal.get();

      PSA_Project__c[] projects = projectDA.getPSAProjectAndOpportunityByProjectId(new Set<Id>{projectId});
      PSA_Project__c project = projects[0];

      Map<String, String> projectMap = buildProjectMap(project, formData);
      viewReference.setParameter('project', projectMap);

      viewReference.setParameter('textInputVisibility', getTextInputVisibility(formData));

      Methodologies_Slack_App_Settings__c settings = Methodologies_Slack_App_Settings__c.getInstance();
      viewReference.setParameter('url', settings.Services_Org_URL__c);

      Project_by_Product_Offerings__c[] projectProducts = projectProductDA.getProjectProductByProjectId(new Set<Id>{projectId});
        
      List<String> productNames = new List<String>();
      for ( Project_by_Product_Offerings__c projectProduct : projectProducts) {
          productNames.add(projectProduct.Product__r.Name);
      }
      String productOfferings = String.join(productNames, '; ');
      
      viewReference.setParameter('productOfferings', productOfferings);
      
      return new Slack.ModalView.Builder().viewReference(viewReference).build();
    }

    private Map<String, Boolean> getTextInputVisibility(Map<String, Object> formData) {
      String methodology = (String)formData.get('customer_methodology_select');
      String projectManagement = (String)formData.get('project_management_tool_select');
      String workManagement = (String)formData.get('work_management_tool_select');
      String cicd = (String)formData.get('cicd_tool_select');
      String automatedTesting = (String)formData.get('automated_testing_tool_select');

      Map<String, Boolean> textInputVisibility = new Map<String, Boolean>{
        'showOtherMethodologyUsed' => methodology != null && methodology.startsWith('Other'),
        'showOtherProjectManagement' => projectManagement != null && projectManagement.startsWith('Other'),
        'showOtherWorkManagement' => workManagement != null && workManagement.startsWith('Other'),
        'showOtherCICD' => cicd != null && cicd.startsWith('Other'),
        'showOtherAutomatedTesting' => automatedTesting != null && automatedTesting.startsWith('Other')
      };

      return textInputVisibility;
    }

    // IMPORTANT: if you do any changes to the mapping here, make sure it's also reflected in MTH_ProjectSetupModalOpen.createProjectMap
    // TODO: consider refactoring to one mapping method
    private Map<String, String> buildProjectMap(PSA_Project__c project, Map<String, Object> formData) {
      Map<String, String> projectMap = new Map<String, String>();
      projectMap.put('Name', String.valueOf(project.Name));
      projectMap.put('Id', project.Id);

      projectMap.put('Engagement_Size__c', (String)formData.get('verify_engagement_sizing_select'));
      projectMap.put('Offering__c', (String)formData.get('offering_select'));
      projectMap.put('Engagement_Type__c', (String)formData.get('engagement_type_select'));

      projectMap.put('Preferred_Methodology__c', (String)formData.get('customer_methodology_select'));
      projectMap.put('Other_Preferred_Methodology__c', (String)formData.get('other_methodology_used'));
      
      projectMap.put('Project_Management_Tool__c', (String)formData.get('project_management_tool_select'));
      projectMap.put('Other_Project_Management_Tool__c', (String)formData.get('other_project_management_tool'));

      projectMap.put('Work_Management_Tool__c', (String)formData.get('work_management_tool_select'));
      projectMap.put('Other_Work_Management_Tool__c', (String)formData.get('other_work_management_tool'));

      projectMap.put('CICD_Tool__c', (String)formData.get('cicd_tool_select'));
      projectMap.put('Other_CICD_Tool__c', (String)formData.get('other_cicd_tool_select'));

      projectMap.put('Automated_Testing_Tool__c', (String)formData.get('automated_testing_tool_select'));
      projectMap.put('Other_Automated_Testing_Tool__c', (String)formData.get('automated_testing_tool'));

      projectMap.put('DAF_Review_Options__c', (String)formData.get('daf_review_options_select'));

      if (String.isNotBlank(String.valueOf(project.Bookings__c))){
        projectMap.put('Bookings__c', String.valueOf((project.Bookings__c).format()));
      }
      
      return projectMap;
    }
  }
}