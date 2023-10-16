({
    doInit: function(cmp, event, helper) {
        var contentRecId = cmp.get("v.contentRecordId");                
        var loadState = cmp.get("v.loading");
        
        var a = cmp.get('c.createCollectionMenu');
        $A.enqueueAction(a);
    },
    createCollectionMenu : function(cmp, event, helper) {
        var contentRecId = cmp.get("v.contentRecordId");                
        var actionGetCollectionDetails = cmp.get("c.getUserCollectionWithContent");        
        var collectionMap = null;
        var menuitems = [];
        actionGetCollectionDetails.setParams({ contentID : contentRecId });
        actionGetCollectionDetails.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                collectionMap = response.getReturnValue();

                if (collectionMap != null) {
                    collectionMap.forEach(function(item, index, array) {
                        var menuitemdata = item.split('|');
                        var menuitemlabel = menuitemdata[0];
                        var menuitemid = menuitemdata[1];
                        var menuitemchecked = menuitemdata[2];
                        menuitemid = menuitemid + "|" + menuitemchecked;
                        var menuitem = null;
                        if (menuitemchecked == "true") {
                            menuitem = {label: menuitemlabel, value: menuitemid, checked: true};
                        } else {
                            menuitem = {label: menuitemlabel, value: menuitemid, checked: false};
                        }                        
                        menuitems.push(menuitem);
                    });
                  
                  cmp.set("v.actions", menuitems);
                }                
                cmp.set("v.loading", false);
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
        $A.enqueueAction(actionGetCollectionDetails);        
    },    
    handleMenuSelect: function(cmp, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        var contentRecId = cmp.get("v.contentRecordId");
        var actionAddToRemoveFrom = cmp.get("c.addToRemoveFromCollection");
        var addRemove;
        var addRemoveResult;
        var menuitemChecked;
        var menuitemValue;

        if (selectedMenuItemValue === "createCollection") {
            var modalBody;
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
                            // DO NOTHING JUST CLOSE THE WINDOW                                
                        }
                    })
                }                               
            });
        } else if (selectedMenuItemValue === "showAllCollections") {
            var userId = $A.get("$SObjectType.CurrentUser.Id");

            var sPageURL = decodeURIComponent(window.location.hostname);
            var PROD = 'dreamportal.force.com';
            var UAT = 'bedrockuat-dreamportal.cs8.force.com';
            
            var urlEvent = $A.get("e.force:navigateToURL");
            var userProfilePageUAT = "/thestation/s/profile/"+userId+"?tabset-5b06e=e5cc2";
            var userProfilePagePROD = "/thestation/s/profile/"+userId+"?tabset-dc735=937b8";            
            
            var userProfilePage = '';

            if (sPageURL == PROD) {
                userProfilePage = userProfilePagePROD;
            } else {
                userProfilePage = userProfilePageUAT;
            }
            urlEvent.setParams({
              "url": userProfilePage
            });
            urlEvent.fire();            
        } else {
            var parcedValue = selectedMenuItemValue.split('|');
            menuitemValue = parcedValue[0];
            menuitemChecked = parcedValue[1];
            var toastMessage = null;            
            if (menuitemChecked == "true") {
                addRemove = false;
                toastMessage = 'Content removed from Collection';
            } else {
                addRemove = true;
                toastMessage = 'Content added to Collection';
            }
            actionAddToRemoveFrom.setParams({ collectionRecordId : menuitemValue, contentId : contentRecId, addToCollection : addRemove});

            actionAddToRemoveFrom.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    addRemoveResult = response.getReturnValue();
                    if (addRemoveResult) {
                        var a = cmp.get('c.createCollectionMenu');
                        $A.enqueueAction(a);
                        
                        helper.showToast(cmp,'Success', toastMessage);
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
            $A.enqueueAction(actionAddToRemoveFrom);                        
        }
    }
})