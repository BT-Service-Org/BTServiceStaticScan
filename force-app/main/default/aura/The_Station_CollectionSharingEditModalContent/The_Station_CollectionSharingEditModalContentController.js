({
    doInit : function(cmp, event, helper) {
        var collectionId = cmp.get("v.collectionRecordId");
        var rowActions = helper.getRowActions.bind(this, cmp);

        cmp.set('v.columns', [
            { label: 'Name', fieldName: 'UserName', type: 'text', hideDefaultActions: true },
            { label: 'Access Level', fieldName: 'AccessLevel', type: 'text', hideDefaultActions: true },
            { type: 'action', typeAttributes: { rowActions: rowActions } }            
        ]);

        var a = cmp.get('c.getManualShareData');
        $A.enqueueAction(a);        
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        var actionRecord = cmp.get("c.updateCollectionSharing");
        var shareUpdate;
        var jsonRow = JSON.stringify(row);
        var share = JSON.parse(jsonRow);
        var record = share.ParentId;
        var userId = share.UserOrGroupId;
        switch (action.name) {
            case 'read':
                actionRecord.setParams({ 
                    collectionRecordId : share.ParentId,
                    userId : share.UserOrGroupId,
                    AccessLevelReadEditRevoke : 'Read'
                });        
                break;
            case 'edit':
                actionRecord.setParams({ 
                    collectionRecordId : share.ParentId,
                    userId : share.UserOrGroupId,
                    AccessLevelReadEditRevoke : 'Edit'
                });        
                break;
            case 'revoke':
                actionRecord.setParams({ 
                    collectionRecordId : share.ParentId,
                    userId : share.UserOrGroupId,
                    AccessLevelReadEditRevoke : 'Revoke'
                });        
            break;
        }
        
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                shareUpdate = response.getReturnValue();
                if (shareUpdate != null) {
                    shareUpdate.forEach(function(record){
                        record.UserName = record.UserOrGroup.Name;
                    });                
                    cmp.set('v.data',shareUpdate);
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
        var groupRecordId = cmp.get("v.collectionRecordId");
        $A.createComponent("c:The_Station_CollectionShareWithUserFlow", 
        { collectionRecordId: groupRecordId }, 
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLibNewShare').showCustomModal({
                    header: "The Station - Share Collection With User",
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {                        
                        var a = cmp.get('c.getManualShareData');
                        $A.enqueueAction(a);
                    }
                });
                var a = cmp.get('c.getManualShareData');
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
        var a = cmp.get('c.getManualShareData');
        $A.enqueueAction(a);
    },
    getManualShareData : function(cmp, event, helper) {
        var actionRecord = cmp.get("c.getCollectionManualShareData");
        var collectionId = cmp.get("v.collectionRecordId");
        var shareData;
        actionRecord.setParams({ 
            collectionRecordId : collectionId
        });
        actionRecord.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                shareData = response.getReturnValue();
                if (shareData != null) {
                    shareData.forEach(function(record){
                        record.UserName = record.UserOrGroup.Name;
                    });                
                    cmp.set('v.data',shareData);
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