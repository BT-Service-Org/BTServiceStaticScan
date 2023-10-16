({
    renderingModal : function(cmp, recordTypeId) {
        var action = cmp.get("c.getRecordTypeName");
        action.setParams({
            recordTypeId: recordTypeId
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var recordTypeName = response.getReturnValue();
                console.log('record type name: '+recordTypeName);
                if(recordTypeName !== 'Draft') {
                    cmp.set('v.isOpen', true);
                    cmp.set("v.message", $A.get("$Label.c.Not_Draft_Method"))
                } else {
                    cmp.set('v.isOpen', true);
                    cmp.set('v.isDraft', true);
                    var flow = cmp.find('flow');
                    flow.startFlow('Create_Method');
                }
            }   
        });
        $A.enqueueAction(action);
    },

    closeFlowModal : function(cmp) {
        cmp.set("v.isOpen", false);
        var keyPrefix;
        var action3 = cmp.get("c.getkeyPrefix");
        action3.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                keyPrefix = response.getReturnValue();
                if(keyPrefix !== undefined) {
                    var link = window.location.origin+'/'+ keyPrefix +'/o';
                    window.open(link, '_top');
                } else {
                    window.open(window.location.origin, '_top');
                }
                
            }   
        });
        $A.enqueueAction(action3);

        // setTimeout(() => {
        //     var link = window.location.origin+'/'+ keyPrefix +'/o';
        //     window.open(link, '_top');
        // },1500)
    }
})