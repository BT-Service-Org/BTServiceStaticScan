({
    doInit:function(component, event, helper){
        try {
            var rId = component.get("v.collectionRecordId");
            var flow = component.find("flowComponentAddToCollection");
			var inputVariables;
            
            inputVariables = [
                { name : "input_CollectionRecordId", type : "String", value: component.get("v.collectionRecordId") }
            ];  
            flow.startFlow("The_Station_Add_Content_To_Collection_Flow", inputVariables);
        } catch (e) {
            alert('Error ' + e);
        }
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") { 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            message: 'Collection Updated. Click \‘Save\’ to view changes',
            duration:' 8000',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();           
        component.find("overlayLib").notifyClose();            
        }
    }    
})