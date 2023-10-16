({
    doInit : function(component, event, helper) {
        component.set("v.oUser",null);
        helper.retrieveUserObject(component, event, helper);	
    }
})