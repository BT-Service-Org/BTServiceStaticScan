({
    loadBadges : function(component) {
        const action = component.get("c.getBadgesProgress");
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            console.log('loadBadges state:  '+state);
            if (state === "SUCCESS") {
                component.set("v.badgesProgress", response.getReturnValue()); 
                 if(response.getReturnValue()==null || response.getReturnValue()==''){  
                    component.set("v.noBadgesToDisplay", true);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    loadProfileUrl : function(component) {
        const action = component.get("c.getProfileUrl");
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            console.log('loadProfileUrl state:  '+state);

            if (state === "SUCCESS") {
                component.set("v.showMoreURL", "https://trailblazer.me/id?lang=en_US");
            }
        });
        
        $A.enqueueAction(action);
    }
})