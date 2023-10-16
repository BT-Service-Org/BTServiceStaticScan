({
    doInit:function(component, event, helper){
        try {
            var rId = component.get("v.collectionRecordId");
            var flow = component.find("flowComponentShareWithUserFlow");
			var inputVariables;
            
            inputVariables = [
                { name : "inputCollectionRecordId", type : "String", value: component.get("v.collectionRecordId") }
            ];  
            flow.startFlow("The_Station_Collection_Sharing_with_User", inputVariables);
        } catch (e) {
            alert('Error ' + e);
        }
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {            
            component.find("overlayLib").notifyClose();            
        }
    }    
})