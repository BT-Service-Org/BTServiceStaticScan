({
    doInit:function(component, event, helper){
        try{
            var flow = component.find("ContentRecordEdit");
			var inputVariables;
            
            
            // SEND INPUTS TO FLOW
				inputVariables = [
                {name : "input_ContentId", type : "String", value: component.get("v.contentId") },
                { name : "input_screenType", type : "String", value: component.get("v.contentEvent")},
                {  name : "input_ContentName", type : "String", value: component.get("v.contentName")}
                ];                
                                     
            flow.startFlow("The_Station_User_Modify_Content_Record", inputVariables);
        } catch (e) {
            alert('Error ' + e);
        }
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {  
            component.set('v.refreshValue','true');             
            component.find("overlayLib").notifyClose(); 
            console.log("event sent");
                 
        }
    } 
})