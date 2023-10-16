({
    doInit:function(component, event, helper){
        try{
            var flow = component.find("SubmitCase");
			var inputVariables;
            
            
            // SEND INPUTS TO FLOW
				inputVariables = [
                {name : "input_OwnerOrQueueId", type : "String", value: component.get("v.UserorQueueId") }
                ];                
                                     
            flow.startFlow("The_Station_Submit_Request_Content_Case", inputVariables);
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