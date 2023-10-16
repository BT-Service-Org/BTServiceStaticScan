({
	onContentDetailsClick: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Content Details',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
	},
	onViewDocument: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'View Document',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
        
        var contentID = event.currentTarget.dataset.key;
        if (contentID) {
            var url = "https://org62.lightning.force.com/contenthub/openintarget?ref_id=" + contentID + "&amp;operationContext=S1"
            var urlEvent = cmp.getEvent("urlEvent");
            urlEvent.setParams({
                "url" : url
            });
            urlEvent.fire();
        }
	},
	onAdditionalLinkClick: function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Additional URL',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    }
})