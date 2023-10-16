({
    initBaseUrl : function(component) {
        const urlString = window.location.href;
        const baseUrl = urlString.substring(0, urlString.indexOf("/s/"));
        component.set("v.cbaseURL", baseUrl + '/s');  
    },
    loadMenu : function(component) {
        var action = component.get("c.getMenus");
        
        action.setParams({
            mainMenu: component.get("v.mainMenu"),
            childMenus: component.get("v.childMenus"),
            baseUrl: component.get("v.cbaseURL")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.menuData', response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    initStylingPreferences: function(component) {
        if (component.get('v.alignment') === 'Left') {
            component.set('v.alignmentClass', '');
        }
        if (component.get('v.alignment') === 'Center') {
            component.set('v.alignmentClass', 'slds-grid_align-center');
        }
        if (component.get('v.alignment') === 'Right') {
            component.set('v.alignmentClass', 'slds-grid_align-end');
        }
    }
})