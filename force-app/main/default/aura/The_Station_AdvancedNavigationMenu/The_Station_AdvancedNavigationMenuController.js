({
    
    doInit: function (component, event, helper) {
        helper.initBaseUrl(component);
        helper.loadMenu(component);
        helper.initStylingPreferences(component);
    },
    onTargetClick: function (component, event, helper) {
        event.preventDefault();
        const target = event.target.dataset.target;
        const baseUrl = component.get("v.cbaseURL");
        if(target) {
            window.open(target, "_self");
        }
        
    }
})