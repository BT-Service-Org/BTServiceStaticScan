({
    getMethodStatus: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getMethodStatus");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    this.callMethodCreationFLow(component, recordID, response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

    callMethodCreationFLow: function(component, recordID, status) {
        this.getGroupingIds(component, recordID);
        this.getStageIds(component, recordID);
        this.getIndustryIds(component, recordID);
        this.getServiceProductIds(component, recordID);
        this.getProductIds(component, recordID);

        const flow = component.find("flowData");
        setTimeout(()=>{
            component.set('v.loader',false)
            console.log('stage ids--->'+component.get('v.stageIds'));
            var inputVariables = [
                { name : "MethodRecordId", type : "String", value: recordID }, 
                { name : "actionType", type : "String", value: "EDIT" },
                { name : "currentStatus", type : "String", value: status }, 
                { name : "defaultGrouping", type : "String", value: component.get('v.groupingIds') },
                { name : "defaultStages", type : "String", value: component.get('v.stageIds') },
                { name : "defaultIndustries", type : "String", value: component.get('v.industryIds') },
                { name : "defaultServiceProducts", type : "String", value: component.get('v.serviceProductIds') },
                { name : "defaultProducts", type : "String", value: component.get('v.productIds') }
              ];
            flow.startFlow("Create_Method", inputVariables);
        },3000);
        
    },

    getStageIds: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getStageIds");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    component.set('v.stageIds', response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

    getGroupingIds: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getGroupingIds");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    component.set('v.groupingIds', response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

    getIndustryIds: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getIndustryIds");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    component.set('v.industryIds', response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

    getServiceProductIds: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getServiceProductIds");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    component.set('v.serviceProductIds', response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

    getProductIds: function(component, recordID) {
        console.log('recordId-: '+recordID);
        var action = component.get("c.getProductIds");
        action.setParams({
            recordId: recordID
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    component.set('v.productIds', response.getReturnValue());
                } 
            }   
        });
        $A.enqueueAction(action);
    },

})