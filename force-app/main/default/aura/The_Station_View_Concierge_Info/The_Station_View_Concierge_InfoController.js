({// Load support_Cases from Salesforce
    doInit: function(component, event, helper) {
        // Create the action
        let action = component.get("c.getSupportCases");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.supportforce_Cases", response.getReturnValue());
           		console.log("getSupportCases > response: " + response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        //
       // helper.loadProfileUrl(component);
    },
})