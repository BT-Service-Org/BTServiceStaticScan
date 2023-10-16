({
    doInit:function(component, event, helper){
        var flow = component.find("createContentCaseFlow");
        var inputVariables = [
            { 
                name : "currRecordId", type : "String", value: component.get("v.sprdRecordId") 
            }
        ];
//        flow.startFlow("CreateTheStationContentCase", inputVariables);
//        flow.startFlow("The_Station_Create_Content_Case_Major_Minor", inputVariables);
        flow.startFlow("The_Station_Request_New_Content_or_Submit_Content_Case", inputVariables);        
         
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            var newCaseNumber;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "newCaseNumber")
                {
                    newCaseNumber = outputVar.value;
                    component.set("v.newCaseNumber",newCaseNumber);
                }
            }
            component.set("v.newCaseNumber", newCaseNumber);
            component.find("overlayLib").notifyClose();
            
        }
    }
    
})