({
    doInit : function(cmp, event, helper) {
        var object = cmp.get("v.stationContentGroup");
        var url = "/thestation/s/station-pages/" + object.Id;        
        cmp.set("v.collectionDetailURL", url);
                
        var actionRecord = cmp.get("c.getCollectionFollowerCount");                
        var record = null;        
        actionRecord.setParams({ 
            collectionRecordId : object.Id
        });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                cmp.set("v.followersNumber", record);
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
        $A.enqueueAction(actionRecord);                
    },
    handleFollow : function(cmp, event, helper) {
        var object = cmp.get("v.stationContentGroup");
        var groupRecordId = object.Id;

        var actionRecord = cmp.get("c.followCollection");                
        var record = null;        
        actionRecord.setParams({ 
            collectionRecordId : groupRecordId
         });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
// NEED EVENT TO POST TO APPLICATION SO IT REFRESHES !!!
                var refreshEvent = $A.get("e.c:The_Station_CollectionUserProfileGridUpdateEvent");
                refreshEvent.setParams({"update" : groupRecordId });
                refreshEvent.fire();                
                
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
        $A.enqueueAction(actionRecord);
    }, 
})