({
    initRecords: function(component, event, helper) {
        var originAction = component.get("c.getLexOriginUrl");
        originAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var origin = response.getReturnValue();
                component.set("v.originUrl", origin);
                component.set("v.url", origin + '/lightning/r/StationGroupingAssociation__c');
                component.set("v.urll", origin + '/lightning/r/Station_Content__c');
                
                var countAction = component.get("c.fetchAssociationCount");
                countAction.setParams({
                    "recordId": component.get("v.recordId")
                });
                countAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var count = response.getReturnValue();
                        component.set("v.listCount", count);
                    }
                });
                $A.enqueueAction(countAction);
                var action = component.get("c.fetchAssociation");
                action.setParams({
                    "recordId": component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        component.set("v.AssociationList", storeResponse);
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(originAction);
    },
    
    Save: function(component, event, helper) {
        if (helper.requiredValidation(component, event)){ 
            var action = component.get("c.saveAssociation");
            action.setParams({
                'lstAssociation': component.get("v.AssociationList")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.AssociationList", storeResponse);
                    component.set("v.showSaveCancelBtn",false);
                    alert('Updated...');
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    
    cancel : function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    },
    
    createAssociation: function (component) {
        var createRecordEvent = $A.get('e.force:createRecord');
        createRecordEvent.setParams({
            'entityApiName': 'StationGroupingAssociation__c',
            'defaultFieldValues': {
                'Station_Page__c' : component.get('v.recordId')
            }
        });
        createRecordEvent.fire(); 
    },
    
    refresh : function(component, event){
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    },
    
    
    
})