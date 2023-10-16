/**
 * @description Handle button click from mth_generic_msg.view
 */
public with sharing class MTH_GenericMsgActionHandler extends Slack.ActionDispatcher {

  public override Slack.ActionHandler invoke(
      Map<String, Object> parameters,
      Slack.RequestContext context
  ) {
      Slack.ActionPayload actionPayload = context.getActionPayload();
      String identifier = String.valueOf(actionPayload.getValue());
      if (identifier.startsWith('retry-smartsheets-creation-')) {
        return Slack.ActionHandler.modal(new RetrySmartsheetsCreationHandler(parameters, context));
      } else {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
      }
  }

  /**
   * @description   Trigger retry of smartsheet creation and then show modal to explain we initiated retry
   */
  public class RetrySmartsheetsCreationHandler implements Slack.ModalHandler {
    Map<String, Object> parameters;
    Slack.RequestContext context;

    public RetrySmartsheetsCreationHandler(Map<String, Object> parameters, Slack.RequestContext context) {
        this.parameters = parameters;
        this.context = context;
    }

    public Slack.ModalView call() {
        Slack.ActionPayload actionPayload = context.getActionPayload();
        String identifier = String.valueOf(actionPayload.getValue());
        Id projectId = (Id) identifier.remove('retry-smartsheets-creation-');
        
        List<EDHQ_BT_RefreshSmartsheetController.InputVariables> inputVars = new List<EDHQ_BT_RefreshSmartsheetController.InputVariables>();
        EDHQ_BT_RefreshSmartsheetController.InputVariables projVar = new EDHQ_BT_RefreshSmartsheetController.InputVariables();
        projVar.projectId = new List<String> { Id.valueOf(projectId) };
        inputVars.add(projVar);

        EDHQ_BT_RefreshSmartsheetController.refreshSmartSheet(inputVars);

        Slack.ViewReference viewReference = Slack.View.mth_generic_modal.get();
        viewReference.setParameter('title', 'Smartsheet Creation');
        viewReference.setParameter('body', 'Initiated a retry of Smartsheet creation');

        return Slack.ModalView.builder()
          .viewReference(viewReference)
          .build();
    }
  }

  public class Handler implements Slack.RunnableHandler {
    Map<String, Object> parameters;
    Slack.RequestContext context;

    public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
        this.parameters = parameters;
        this.context = context;
    }

    public void run() {
    }
  }
}