({
    doInit : function (cmp, event, helper) {
        var recId = cmp.get("v.contentRecordId");
        
        var action = cmp.get("c.isContentLikedByRunningUser");
        var action1 = cmp.get("c.getLikeCount");                
        var setLike = false;
        action.setParams({ stationContentRecordId : recId });
        action1.setParams({ stationContentRecordId : recId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                setLike = response.getReturnValue();
                cmp.set("v.contentLikeState", setLike);
                action1.setCallback(this, function(response1) {
                    var state1 = response1.getState();
                    if (state1 === "SUCCESS") {
                        cmp.set("v.numberLikes", response1.getReturnValue());
                    }
                })
                $A.enqueueAction(action1);
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
        var likeNumber = event.getParam("numberLikes")
        var thisButton = cmp.get("v.contentRecordId");
        if(thisButton == recId) {
            cmp.set("v.contentLikeState", state);
            cmp.set("v.numberLikes",likeNumber);
        }   
          
    },    
    handleLikeButtonClick : function (cmp, event, helper) {
        var target = event.getSource();        
        var contentRecordId = target.get("v.value");
        var action = cmp.get("c.LikeContent");
        var action1 = cmp.get("c.getLikeCount");
        var likeNumber = 0;                 
        var setLike = false;
        action.setParams({ stationContentRecordId : contentRecordId });
        action1.setParams({ stationContentRecordId : contentRecordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                setLike = response.getReturnValue();
                cmp.set("v.contentLikeState", setLike);

                action1.setCallback(this, function(response1) {
                    var state1 = response1.getState();
                    if (state1 === "SUCCESS") {
                        likeNumber = response1.getReturnValue();
                        cmp.set("v.numberLikes", likeNumber);
                
                var appEvent = $A.get("e.c:The_Station_ContentLikeEvent");
                appEvent.setParams({
                    "stationContentRecordId" : contentRecordId,
                    "changeState" : setLike,
                    "numberLikes" : likeNumber});
                   
                appEvent.fire();  
            }
        })
    $A.enqueueAction(action1);      
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

        // var userId = $A.get("$SObjectType.CurrentUser.Id");
        // var eventCategory = userId + " : Button";
        // var name = target.get("v.name");
        // var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");

        // analyticsInteraction.setParams({
        //     hitType : 'event',
        //     eventCategory : eventCategory,
        //     eventAction : 'Favorite Content',
        //     eventLabel : name,
        //     eventValue: 1
        // });
        // analyticsInteraction.fire();
    }
})