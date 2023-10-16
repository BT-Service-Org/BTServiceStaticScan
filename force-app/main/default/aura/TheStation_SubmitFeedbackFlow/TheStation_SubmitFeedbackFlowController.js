({
    doInit:function(component, event, helper){
        var flow = component.find("submitFeedbackFlow");
        
//        flow.startFlow("The_Station_Submit_Feedback");
        flow.startFlow("The_Station_Submit_Feedback_Case");         
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            
            component.find("overlayLib").notifyClose();
            
        }
    }
    
})