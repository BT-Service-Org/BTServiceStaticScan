({
    doInit : function(component, event, helper) {

    },
    
    switchProfileView : function(component, event, helper){
        let switchViewEvent = component.getEvent("switchViewEvent");
        let buttonSelectedId  = event.getSource().getLocalId();
        let oldButtonSelected = component.get("v.buttonSelected");
        $A.util.removeClass(component.find(oldButtonSelected), 'selected-button');
        $A.util.addClass(component.find(buttonSelectedId), 'selected-button');
        component.set("v.buttonSelected",buttonSelectedId);
        switchViewEvent.setParams({ "divToShow" : event.getSource().getLocalId() });
        switchViewEvent.fire();

    }
})