({
    doInit : function(component, event, helper) {
        var myAction = component.get("c.connectedUser");
        myAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.connectedUser", response.getReturnValue());
            }});
        $A.enqueueAction(myAction);
    },
    routeModal : function(component,view,upd,del){
        component.set("v.viewMode", view);
        component.set("v.updateMode", upd);
        component.set("v.deleteMode", del);
    },

})