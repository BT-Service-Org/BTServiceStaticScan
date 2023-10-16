({
    fetchGroups : function(component, event) {
        var action = component.get("c.getSCGroupNames");
        var scID=component.get("v.scId");
        action.setParams({
            ContentId : scID
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();  
                component.set("v.GroupList", records);
            }            
        });
        $A.enqueueAction(action);
 }
})