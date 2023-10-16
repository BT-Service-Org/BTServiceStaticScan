/**
 * Renders manage project view of home page when "Manage" button is clicked or user paginates through list of projects
 */
public with sharing class MTH_ManageProjectViewHandler extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
      return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {      
      
      Map<String, Object> parameters;
      Slack.RequestContext context;
      
      public Handler (Map<String, Object> parameters, Slack.RequestContext context){
          this.parameters = parameters;
          this.context = context;
      }
      
      public void run () {
        String teamId = context.getTeamId();
        Id projectId = (Id)parameters.get('projectId');

        String pageAction = null;
        Integer prevPaginatorPage = null;
        Integer prevTotalPages = null;
        
        // handle pagination if we were invoked by a user clicking previous/next button
        if (parameters != null && parameters.get('paginator') != null) {
            Map<Object, Object> prevPaginatorParam = (Map<Object, Object>) ((List<Object>) parameters.get(
                'paginator'
            ))
            .iterator()
            .next();

            prevPaginatorPage = Integer.valueOf(prevPaginatorParam.get('currPage'));
            prevTotalPages = Integer.valueOf(prevPaginatorParam.get('totalPages'));

            pageAction = context.getActionPayload().getName();
        }

        // handle user selecting a specific page to go to
        if (context.getFormData() != null) {
          for (String key : context.getFormData().keySet()) {
            Object value = context.getFormData().get(key);
            if (key.equals('method_page_select') && value != null) {
              prevPaginatorPage = Integer.valueOf(value) - 1;
              pageAction = new MTH_Pagination().NEXT_PAGE;
              break;
            }
          }
        }
        
        String slackId = MTH_SlackUserIdHandler.getSlackIdFromContextOrRunningUserId(context);
        MTH_ManageProjectViewOpen.buildHomeView(projectId, teamId, slackId, pageAction, prevPaginatorPage, prevTotalPages);
      }
  }   
}