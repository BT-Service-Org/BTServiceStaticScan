/**
 * @description Called when user clicks buttons on app home page to paginate projects.
 */
public with sharing class MTH_ProjectPaginate extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new MTH_AppHomeOpen.Handler(parameters, context));
    }
}