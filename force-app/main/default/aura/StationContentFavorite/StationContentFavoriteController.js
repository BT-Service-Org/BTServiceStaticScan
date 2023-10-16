({
    doInit : function(cmp, event, helper) {
        var favorites;
        var userAction = cmp.get("c.getUserFavorites");
        userAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                favorites = response.getReturnValue();
                cmp.set('v.favoriteContentRecords',favorites);
            }
        });
        $A.enqueueAction(userAction);        
    },
    handleFavoriteEvent : function(cmp, event) {
        var contentRecordId = event.getParam("stationContentRecordId");
        var state = event.getParam("currentState");
        var userId = event.getParam("runningUser");
        var action = cmp.get("c.updateUserStationContentFavorite");
        var setFavorite = false;
        action.setParams({ stationContentRecordId : contentRecordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                setFavorite = response.getReturnValue();
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
    }
})