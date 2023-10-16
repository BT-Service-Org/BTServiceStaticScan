({
    onDownloadClick: function (cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: eventCategory,
            eventAction: 'Download',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    }
})