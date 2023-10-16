({
    doInit: function(component, event, helper) {
        var recordID;
        if ( component.get('v.recordId') !== undefined ) {
            recordID = component.get('v.recordId');
            helper.getMethodStatus(component, recordID)            
        }
    },

})