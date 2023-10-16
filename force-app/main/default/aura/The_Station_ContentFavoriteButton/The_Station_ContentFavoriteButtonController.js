({
    doInit : function (cmp, event, helper) {
        var recId = cmp.get("v.contentRecordId");
        
        var action = cmp.get("c.isContentFavoriteByRunningUser");                
        var setFavorite = false;
        action.setParams({ stationContentRecordId : recId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                setFavorite = response.getReturnValue();
                cmp.set("v.contentFavoriteState", setFavorite);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleApplicationEvent : function (cmp, event, helper) {
        var recId = event.getParam("stationContentRecordId");
        var state = event.getParam("changeState");
        var thisButton = cmp.get("v.contentRecordId");
        if(thisButton == recId) {
            cmp.set("v.contentFavoriteState", state);
        }        
    },    
    handleFavoriteButtonClick : function (cmp, event, helper) {
        var target = event.getSource();        
        var contentRecordId = target.get("v.value");
        var action = cmp.get("c.createStationCollectionFavorite");                
        var setFavorite = false;
        action.setParams({ stationContentRecordId : contentRecordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                setFavorite = response.getReturnValue();
                cmp.set("v.contentFavoriteState", setFavorite);
                var appEvent = $A.get("e.c:The_Station_ContentFavoriteEvent");
                appEvent.setParams({
                    "stationContentRecordId" : contentRecordId,
                    "changeState" : setFavorite});
                appEvent.fire();        
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";
        var name = target.get("v.name");
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");

        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Favorite Content',
            eventLabel : name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    }
})