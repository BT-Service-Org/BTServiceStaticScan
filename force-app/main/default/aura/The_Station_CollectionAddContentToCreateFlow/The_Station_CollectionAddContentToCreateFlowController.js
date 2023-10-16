({
    doInit:function(component, event, helper){
        try {
            var rId = component.get("v.contentRecordId");
            var flow = component.find("flowComponentCreateCollection");
			var inputVariables;
            
            inputVariables = [
                { name : "input_contentRecordId", type : "String", value: component.get("v.contentRecordId") }
            ];  
            flow.startFlow("The_Station_Create_Collection_Flow", inputVariables);
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