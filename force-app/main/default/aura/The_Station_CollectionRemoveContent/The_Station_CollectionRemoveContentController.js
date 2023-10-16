({
    doInit:function(component, event, helper){
        try{
            var flow = component.find("RemoveContent");
            var inputVariables;
            var id1 = component.get("v.collectionId");
            var Id2 = component.get("v.contentId");            
            
            // SEND INPUTS TO FLOW
				inputVariables = [
                {name : "input_collectionId", type : "String", value: component.get("v.collectionId") },
                { name : "input_contentId", type : "String", value: component.get("v.contentId")}
                ];                
                                     
            flow.startFlow("The_Station_Collection_Remove_Content", inputVariables);
        } catch (e) {
            alert('Error ' + e);
            console.log(e);
        }
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {  
            component.set("v.isDeleted",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            message: 'Content has been successfully removed from the collection',
            duration:' 8000',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();               
            component.find("overlayLib").notifyClose(); 
                 
        }
    } 
})