({
    doInit:function(component, event, helper){
        try{
            var flow = component.find("submitFeedbackFlow");
			var inputVariables;
            
            // HANDLE NULL FOR ORG INSTANCE URL
            var url = component.get("v.orgInstanceUrl");
            if (url != null) {
                // DO NOTHING
            } else {
                // JUST SET TO EMPTY STRING
                url = ''; 
            }
            
            // HANDLE NULL FOR PRIMARY CONTACT
            var primaryContact = component.get("v.cspRecordPrimaryID");
            if (primaryContact != null) {
                // IF PRIMARY CONTACT IS NOT NULL THEN DO SEND IT OVER TO THE FLOW
				inputVariables = [
                { 
                    name : "SPRecordID", type : "String", value: component.get("v.cspRecordId") 
                },
                {
                    name : "SPRecordOwnerID", type : "String", value: component.get("v.cspRecordOwnerID") 
                },
                {
                    name : "SPRecordPrimaryID", type : "String", value: component.get("v.cspRecordPrimaryID") 
                },
                {
                    name : "SPRecordTitle", type : "String", value: component.get("v.cspRecordTitle") 
                },
                {
                    name : "OrgInstanceURL", type : "String", value: url 
                }
            	];                
            } else {
                // IF PRIMARY CONTACT IS NULL THEN DON'T SEND IT OVER TO THE FLOW
				inputVariables = [
                { 
                    name : "SPRecordID", type : "String", value: component.get("v.cspRecordId") 
                },
                {
                    name : "SPRecordOwnerID", type : "String", value: component.get("v.cspRecordOwnerID") 
                },                
                {
                    name : "SPRecordTitle", type : "String", value: component.get("v.cspRecordTitle") 
                },
                {
                    name : "OrgInstanceURL", type : "String", value: url 
                }
                ];          
            }                          
            flow.startFlow("The_Station_SP_Feedback_To_SI", inputVariables);
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