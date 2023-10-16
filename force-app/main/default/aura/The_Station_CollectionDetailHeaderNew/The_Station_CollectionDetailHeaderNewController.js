({
    doInit : function(cmp, event, helper) {  
        
        const MAX_CONTRIBUTORS_TO_DISPLAY = 4;

        var groupRecordId = cmp.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var actionCount = cmp.get("c.getCollectionFollowerCount");                
        var count = 0;

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

        var a = cmp.get('c.getCollectionDetails');
        $A.enqueueAction(a);

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

        var actionShared = cmp.get("c.isPrivateCollectionShared");                
        var isShared = false;
        actionShared.setParams({ collectionRecordId : groupRecordId });
        actionShared.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                isShared = response.getReturnValue();
                cmp.set("v.collectionIsShared", isShared);
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
        $A.enqueueAction(actionShared);
        
// LOCAL CONTRIBUTORS
        var actionContrib = cmp.get("c.getCollectionsContributors");
        var contribs = null;        
        actionContrib.setParams({ collectionRecordId : groupRecordId });
        actionContrib.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                contribs = response.getReturnValue();
                var listOfObjects = [];
                contribs.forEach(function(entry) {
                    var singleObj = {};
                    singleObj['name'] = entry.Name;
                    singleObj['picture'] = entry.MediumPhotoUrl;
                    var sPageURL = decodeURIComponent(window.location.hostname);
                    var PROD = 'dreamportal.force.com';
                    var UAT = 'bedrockuat-dreamportal.cs8.force.com';
            
                    var profilePhotoUAT = "https://sfservices--BedrockUAT--c.cs8.content.force.com/profilephoto/005/M";
                    var profilePhotoPROD = "https://sfservices--c.na138.content.force.com/profilephoto/005/M";
            
                    var profilePhotoURL = '';

                    if (sPageURL == PROD) {
                        profilePhotoURL = profilePhotoPROD;
                    } else {
                        profilePhotoURL = profilePhotoUAT;
                    }

                    var img = new Image();
                    img.onload = function() {
                        singleObj['picture'] = entry.MediumPhotoUrl;
                    }
                    img.onerror = function() {
                        singleObj['picture'] = profilePhotoURL;
                    }
                    img.src = entry.MediumPhotoUrl;
                    listOfObjects.push(singleObj);
                });
                cmp.set("v.contributors", listOfObjects);                
                cmp.set("v.totalContributors", listOfObjects.length);
                const contributors = cmp.get('v.contributors');                
                cmp.set('v.displayedContributors', contributors.slice(0, MAX_CONTRIBUTORS_TO_DISPLAY));
                if(contributors.length >= MAX_CONTRIBUTORS_TO_DISPLAY) {
                    cmp.set('v.moreContributors', contributors.length - MAX_CONTRIBUTORS_TO_DISPLAY);
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
        $A.enqueueAction(actionContrib);


// ORG62 CONTRIBUTORS
/*
        var actionContrib = cmp.get("c.getCollectionsContributorsOrg62");                        

        var contribs = null;        
        actionContrib.setParams({ collectionRecordId : groupRecordId });
        actionContrib.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                contribs = response.getReturnValue();
                var listOfObjects = [];
                contribs.forEach(function(entry) {
                    var singleObj = {};
                    singleObj['name'] = entry.Name;
                    singleObj['picture'] = entry.MediumPhotoUrl;
                    singleObj['name'] = entry.Name__c;

                    var sPageURL = decodeURIComponent(window.location.hostname);
                    var PROD = 'dreamportal.force.com';
                    var UAT = 'bedrockuat-dreamportal.cs8.force.com';
            
                    var profilePhotoUAT = "https://sfservices--BedrockUAT--c.cs8.content.force.com/profilephoto/005/M";
                    var profilePhotoPROD = "https://sfservices--c.na138.content.force.com/profilephoto/005/M";
            
                    var profilePhotoURL = '';

                    if (sPageURL == PROD) {
                        profilePhotoURL = profilePhotoPROD;
                    } else {
                        profilePhotoURL = profilePhotoUAT;
                    }

                    var img = new Image();
                    img.onload = function() {
                        singleObj['picture'] = entry.SmallPhotoUrl__c;
                    }
                    img.onerror = function() {
                        singleObj['picture'] = profilePhotoURL;
                    }
                    img.src = entry.SmallPhotoUrl__c;

                    listOfObjects.push(singleObj);
                });
                cmp.set("v.contributors", listOfObjects);                
                cmp.set("v.totalContributors", listOfObjects.length);
                const contributors = cmp.get('v.contributors');                
                cmp.set('v.displayedContributors', contributors.slice(0, MAX_CONTRIBUTORS_TO_DISPLAY));
                if(contributors.length >= MAX_CONTRIBUTORS_TO_DISPLAY) {
                    cmp.set('v.moreContributors', contributors.length - MAX_CONTRIBUTORS_TO_DISPLAY);
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
        $A.enqueueAction(actionContrib);
*/        
// org62 contributors ends here

        var actionRunnerCanEdit = cmp.get("c.isCollectionEditableByRunningUser");                
        var isEditable = false;
        actionRunnerCanEdit.setParams({ collectionRecordId : groupRecordId });
        actionRunnerCanEdit.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                isEditable = response.getReturnValue();
                cmp.set("v.collectionIsEditableByRunningUser", isEditable);
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
        $A.enqueueAction(actionRunnerCanEdit);

        
        // helper.configureTheme(cmp);     

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
        cmp.set("v.collectionNameTemp",cmp.get("v.collectionName"));
        cmp.set("v.collectionDescriptionTemp", cmp.get("v.collectionDescription"));
        cmp.set("v.bannerBackgroundColorTemp", cmp.get("v.bannerBackgroundColor")); //CHECK
       
        var modeEvent = $A.get("e.c:The_Station_CollectionModeEvent");
        modeEvent.setParams({
            "mode" : "Edit"  });
            modeEvent.fire();
        
    },
    handleCancel : function(cmp, event, helper) {
        cmp.set("v.editMode", false);
        cmp.set("v.collectionName", cmp.get("v.collectionNameTemp"));
        cmp.set("v.collectionDescription", cmp.get("v.collectionDescriptionTemp"));
        cmp.set("v.bannerBackgroundColor", cmp.get("v.bannerBackgroundColorTemp")); //CHECK
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
        var newBkColor = cmp.find("backColorSelect").get("v.value"); //CHECK
        var actionRecord = cmp.get("c.updateCollection");                
        var record = null;        
        actionRecord.setParams({ 
            collectionRecordId : groupRecordId,
            newName : newTitle,
            newDesc : newDescription,
            newColor : newBkColor,  //CHECK
            visibility : vis
         });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                cmp.set("v.collectionName", newTitle);
                cmp.set("v.collectionDescription", newDescription);
                cmp.set("v.collectionIsPrivate", vis);
                cmp.set("v.bannerBackgroundColor", newBkColor); //CHECK
                cmp.set("v.editMode", false);

                // MOVED EVENT TO AFTER SAVE RETURNS SUCCESSFULLY
                var modeEvent = $A.get("e.c:The_Station_CollectionModeEvent");
                modeEvent.setParams({
                    "mode" : "Save"  });
                    modeEvent.fire();

                var a = cmp.get('c.getCollectionDetails');
                $A.enqueueAction(a);
                    
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
                    // Prevent fc ( FollowerCount ) from ever being below 0
                    if(fc>0) {
                        fc = fc - 1;
                    }
                    cmp.set("v.collectionFollowers", fc);
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
        var modalBody;
        var groupRecordId = cmp.get("v.recordId");
        $A.createComponent("c:The_Station_CollectionShareWithUserFlow", 
        { collectionRecordId: groupRecordId }, 
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: "The Station - Share Collection With User",
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {
                        $A.get('e.force:refreshView').fire();
                        cmp.set("v.collectionIsShared", true);
                    }
                })
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
    },
    editSharing : function(cmp, evt, helper) {
        var modalBody;
        var groupRecordId = cmp.get("v.recordId");
        $A.createComponent("c:The_Station_CollectionSharingEditModalContent", 
        { collectionRecordId: groupRecordId }, 
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: "The Station - Collection Sharing",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {
                        $A.get('e.force:refreshView').fire();
                    }
                })
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
    },

    getCollectionDetails : function(cmp, evt, helper) {
        var groupRecordId = cmp.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var colors = [
                        { value : "rgb(50, 29, 113, 1)", label: "Platform" },
            //            { value : "rgb(201, 150, 182, 0.3)", label : "Rose" },
                        { value : "rgb(138, 3, 62, 1)", label: "Service" },
            //            { value : "rgb(125, 82, 194, 0.3)", label : "Lavender" },
                        { value : "rgb(72, 26, 84, 1)", label: "Industries" },
            //            { value : "rgb(134, 200, 188, 0.3)", label : "Mint" },
                        { value : "rgb(11, 130, 124, 1)", label: "Sales" },
            //            { value : "rgb(167, 171, 142, 0.3)", label : "Silver" },
                        { value : "rgb(57, 101, 71, 1)", label: "Commerce" },
            //            { value : "rgb(249, 225, 124, 0.3)", label : "Lemon" },
                        { value : "rgb(221, 122, 1, 1)", label: "Marketing" },
            //            { value : "rgb(253, 190, 134, 0.3)", label : "Peach" },
                        { value : "rgb(216, 58, 0, 1)", label: "Employees" },
            //            { value : "rgb(234, 167, 148, 0.3)", label : "Blush" },
                        ];        

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

                var i;
                for (i=0; i<colors.length; i++) {
                    if (colors[i].value == record.Collection_Header_Background_Color__c) {
                        cmp.set("v.bannerBackgroundColorSelectedValue", colors[i].value);                                                
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
    }
})