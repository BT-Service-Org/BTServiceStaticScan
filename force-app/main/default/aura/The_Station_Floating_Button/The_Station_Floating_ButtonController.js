({
    redirectToURL: function (component, event, helper) {
        var buttonURL = component.get("v.buttonURL");
        window.open(buttonURL, "_blank")
    }

})