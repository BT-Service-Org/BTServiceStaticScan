({
    getVisibilityPicklist: function(component, event) {
        var action = component.get("c.getVisibilty");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var visibilityMap = [];
                for(var key in result){
                    visibilityMap.push({key: key, value: result[key]});
                }
                component.set("v.visibilityMap", visibilityMap);
            }
        });
        $A.enqueueAction(action);
    },
     
    
    getContentTypePicklist: function(component, event) {
        var action = component.get("c.getContentType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var contentTypeMap = [];
                for(var key in result){
                    contentTypeMap.push({key: key, value: result[key]});
                }
                component.set("v.contentTypeMap", contentTypeMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    
    

    saveContent : function(component, event) {
        var content = component.get("v.content");
        var action = component.get("c.createRecord");
        action.setParams({
            content : content
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                alert('Record is Created Successfully');
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action);
    }
})