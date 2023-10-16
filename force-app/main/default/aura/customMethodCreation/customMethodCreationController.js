({
    doInit : function(component, event, helper) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        helper.renderingModal(component, recordTypeId);     
     },
 
    closeFlowModal : function(component, event, helper) {
        helper.closeFlowModal(component);  
    },
    
    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    }
})