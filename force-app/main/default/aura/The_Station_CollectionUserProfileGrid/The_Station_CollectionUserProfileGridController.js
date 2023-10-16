({
	doInit : function(cmp, event, helper) {
        var opts = [
            { value: "Last Updated", label: "Last Updated", selected: true },
            { value: "Created Date", label: "Created Date" },
            { value: "Alphabetical", label: "Alphabetical" }];
            
        cmp.set('v.options', opts);
        cmp.set('v.selectedValue', 'Last Updated');

        var a = cmp.get('c.doSort');
        $A.enqueueAction(a);

        /* THIS LOOKS AT THE COLLECTION FILTER SO IF YOU CHANGE THE FILTER THEN CHANGE THIS AS NEEDED */
        var cf = cmp.get('v.collectionFilter');
        if (cf=="Shared with me") {
            cmp.set('v.showFollowCollection', true);
        } else {
            cmp.set('v.showFollowCollection', false);
        }      
    },
    newCollection : function(cmp, event, helper) {
        var modalBody;
        var contentRecId = "";
        $A.createComponent("c:The_Station_CollectionAddContentToCreateFlow", 
        { contentRecordId: contentRecId }, 
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: "The Station - Create Collection",
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {
                        $A.get('e.force:refreshView').fire();
                        // THE FOLLOWING CODE UPDATES THE MY COLLECTIONS LIST !!!
                        var filter = cmp.get("v.collectionFilterTitle");
                        if (filter == 'My Collections') {
                            var collection = null;
                            var action = null;    
                            action = cmp.get("c.getUserOwnedCollections");
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    collection = response.getReturnValue();                    
                                    cmp.set("v.collectionList", collection);                       
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
                    }
                })
            }                               
        });
    },
    doSort : function(cmp, event, helper) {
        var filter = cmp.get("v.collectionFilter");
        var sort = cmp.find("collectionSort").get("v.value");
        var sortT = cmp.get('v.selectedValue');
        var collection = null;
        var action = null;
        switch (filter) {
            case "My Collections":                
                action = cmp.get("c.getUserOwnedCollections");        
                break;
            case "Followed Collections":
                action = cmp.get("c.getUserFollowedCollections");                                        
                break;
            case "Shared with me":
                action = cmp.get("c.getSharedWithUserCollections");                                        
                break;    
        }
        action.setParams({
            sortType :  cmp.get('v.selectedValue')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                collection = response.getReturnValue();
                cmp.set("v.collectionList", collection);                       
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