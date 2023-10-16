({
    doInit : function(component, event, helper) {

    },
    
    handleSwitchProfileView : function(component, event, helper){        
        var divToShow =event.getParam("divToShow");
        var viewDisplayed = component.get("v.viewToDisplay");
       	var areaToHide = component.find(viewDisplayed);
        var areaToShow = component.find(divToShow);
        $A.util.addClass(areaToHide, "slds-hide");
        $A.util.removeClass(areaToShow, "slds-hide");
        component.set("v.viewToDisplay",divToShow);
    }
})