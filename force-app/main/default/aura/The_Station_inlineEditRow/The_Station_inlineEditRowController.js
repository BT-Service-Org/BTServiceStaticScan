({
    inlineEditOrder : function(component,event,helper){   
        component.set("v.orderEditMode", true); 
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    
    onOrderChange : function(component,event,helper){ 
        var value = event.getSource().get("v.value");
        if(value > 0 && value % 1 === 0){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },
    
    closeOrderBox : function (component, event, helper) {   
        component.set("v.orderEditMode", false);   
        var value = event.getSource().get("v.value");
        if(value < 1 || isNaN(value) || value % 1 > 0){
            component.set("v.showErrorClass",true);
        } else {
            component.set("v.showErrorClass",false);
        }
    },
    
    handleMenuSelect: function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
        var id = component.get('v.singleRec').Id;
        switch(menuValue) {
            case "edit": helper.doEdit(id); break;
            case "delete":  
                var action = component.get("c.delteAssociationBId");
                action.setParams({
                    recordId: id
                });
                action.setCallback(this, function(response) {
                    component.set("v.singleRec",response.getReturnValue());
                    component.set("v.reloadForm", true);
                });
                $A.enqueueAction(action);
                location.reload(true);
                break;
        }
    }
})