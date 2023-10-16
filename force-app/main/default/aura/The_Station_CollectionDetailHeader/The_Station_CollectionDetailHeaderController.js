({
	doInit : function(cmp, event, helper) {    
        var groupRecordId = cmp.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var actionCount = cmp.get("c.getCollectionFollowerCount");                
        var count = 0;
        var colors = [
                        { value : "rgb(201, 150, 182, 0.3)", label : "Rose" },
                        { value : "rgb(125, 82, 194, 0.3)", label : "Lavender" },
                        { value : "rgb(134, 200, 188, 0.3)", label : "Mint" },
                        { value : "rgb(167, 171, 142, 0.3)", label : "Silver" },
                        { value : "rgb(249, 225, 124, 0.3)", label : "Lemon" },
                        { value : "rgb(253, 190, 134, 0.3)", label : "Peach" },
                        { value : "rgb(234, 167, 148, 0.3)", label : "Blush" },
                        ];

        actionCount.setParams({ collectionRecordId : groupRecordId });
        actionCount.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                count = response.getReturnValue();
                cmp.set("v.collectionFollowers", count);
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
        $A.enqueueAction(actionCount);

        var actionRecord = cmp.get("c.getSpecificCollection");                
        var record = null;        
        actionRecord.setParams({ collectionRecordId : groupRecordId });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                cmp.set("v.collectionRecord", record);
                cmp.set("v.collectionName", record.Name);
                cmp.set("v.bannerBackgroundColor", record.Collection_Header_Background_Color__c);
                cmp.set("v.collectionContentCount", record.Associated_Content_Count__c);
                cmp.set("v.collectionCreatedBy", record.CreatedBy.Name);
                cmp.set("v.collectionDescription", record.Group_Subtitle__c); 
                cmp.set("v.collectionOwnerId", record.OwnerId);
                cmp.set("v.collectionIsPrivate", record.Private_Collection__c);                
                // NEED TO SET THE PICKLIST SELECTED ATTRIBUTE ON THE COLOR FROM THE record.Collection_Header_Background_Color__c
                var i;
                for (i=0; i<colors.length; i++) {
                    if (colors[i].value == record.Collection_Header_Background_Color__c) {
                        colors[i].selected = true;
                    }
                }
                cmp.set("v.backgroundColorOptions", colors);
                

                // THIS MAY NEED TO CHANGE TO DOES THE RUNNING USER HAVE EDIT RIGHTS ON THE COLLECTION ??
                if (record.OwnerId === userId) {   
                    cmp.set("v.collectionIsOwnedByRunningUser", true);
                } else {
                    cmp.set("v.collectionIsOwnedByRunningUser", false);
                }

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

        var actionFollowed = cmp.get("c.isUserFollowingCollections");                
        var isFollowed = false;
        actionFollowed.setParams({ collectionRecordId : groupRecordId });
        actionFollowed.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                isFollowed = response.getReturnValue();
                cmp.set("v.collectionIsFollowedByRunningUser", isFollowed);
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
        $A.enqueueAction(actionFollowed);
        
        helper.configureTheme(cmp);     

    },
    changeHeaderBackgroundColor : function(cmp, event, helper) {
        var selectedColor = cmp.find("backColorSelect").get("v.value");
        cmp.set("v.bannerBackgroundColor", selectedColor);
    },
    handleBackClick : function(cmp, event, helper) {
        window.history.back();
    },
    handleEdit : function(cmp, event, helper) {
        cmp.set("v.editMode", true);
        cmp.set("v.showTitle", false);
        cmp.set("v.showDescription", false);
        cmp.set("v.showEdit", false);
        cmp.set("v.showSave", true);

        cmp.set("v.collectionNameTemp",cmp.get("v.collectionName"));
        cmp.set("v.collectionDescriptionTemp", cmp.get("v.collectionDescription"));
        cmp.set("v.bannerBackgroundColorTemp", cmp.get("v.bannerBackgroundColor"));
        var modeEvent = $A.get("e.c:The_Station_CollectionModeEvent");
        modeEvent.setParams({
            "mode" : "Edit"  });
            modeEvent.fire();
        
    },
    handleCancel : function(cmp, event, helper) {
        cmp.set("v.editMode", false);
        cmp.set("v.showTitle", true);
        cmp.set("v.showDescription", true);
        cmp.set("v.showEdit", true);
        cmp.set("v.showSave", false);

        cmp.set("v.collectionName", cmp.get("v.collectionNameTemp"));
        cmp.set("v.collectionDescription", cmp.get("v.collectionDescriptionTemp"));
        cmp.set("v.bannerBackgroundColor", cmp.get("v.bannerBackgroundColorTemp"));
        var modeEvent = $A.get("e.c:The_Station_CollectionModeEvent");
        modeEvent.setParams({
            "mode" : "Save"  });
            modeEvent.fire();

    },
    handleSave : function(cmp, event, helper) {
        var groupRecordId = cmp.get("v.recordId");
        var newTitle = cmp.find("collectionName").get("v.value");
        var newDescription = cmp.find("collectionDescription").get("v.value");
        var vis = cmp.find("collectionVisibility").get("v.checked");
        var newBkColor = cmp.find("backColorSelect").get("v.value");

        var actionRecord = cmp.get("c.updateCollection");                
        var record = null;        
        actionRecord.setParams({ 
            collectionRecordId : groupRecordId,
            newName : newTitle,
            newDesc : newDescription,
            newColor : newBkColor,
            visibility : vis
         });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                cmp.set("v.collectionName", newTitle);
                cmp.set("v.collectionDescription", newDescription);
                cmp.set("v.collectionIsPrivate", vis);
                cmp.set("v.bannerBackgroundColor", newBkColor);
                cmp.set("v.editMode", false);
                cmp.set("v.showTitle", true);
                cmp.set("v.showDescription", true);
                cmp.set("v.showEdit", true);
                cmp.set("v.showSave", false);
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

        var modeEvent = $A.get("e.c:The_Station_CollectionModeEvent");
        modeEvent.setParams({
            "mode" : "Save"  });
            modeEvent.fire();
    },    
    handleDelete : function(cmp, event, helper) {
        var groupRecordId = cmp.get("v.recordId");

        var confirmDelete = confirm("Are you sure you want to delete this collection ?");
        if (confirmDelete == true) {
            var actionRecord = cmp.get("c.deleteCollection");                
            var record = null;        
            actionRecord.setParams({ 
                collectionRecordId : groupRecordId
            });
            actionRecord.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    record = response.getReturnValue();
                    // Deleted - go back ?
                    window.history.back();
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
        }   
    },
    handleFollow : function(cmp, event, helper) {
        var groupRecordId = cmp.get("v.recordId");
        var userFollow = cmp.get("v.collectionIsFollowedByRunningUser");
        var fc = cmp.get("v.collectionFollowers");

        var actionRecord = cmp.get("c.followCollection");                
        var record = null;        
        actionRecord.setParams({ 
            collectionRecordId : groupRecordId
         });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                if (userFollow) {
                    cmp.set("v.collectionFollowers", fc-1);
                    cmp.set("v.collectionIsFollowedByRunningUser", false);                    
                } else {
                    cmp.set("v.collectionFollowers", fc+1);
                    cmp.set("v.collectionIsFollowedByRunningUser", true);
                }
                
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
    handleShare : function(cmp, event, helper) {
    var isShared = cmp.get("v.collectionIsShared");
    cmp.set("v.collectionIsShared", !isShared);
    }    
})