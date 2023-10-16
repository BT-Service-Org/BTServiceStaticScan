public with sharing class MTH_BackToAppHomeHandler extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(
        Map<String, Object> parameters,
        Slack.RequestContext context
    ) {
        return Slack.ActionHandler.ack(new MTH_AppHomeOpen.Handler(context));
    }
}