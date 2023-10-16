({
    showToast : function(cmp, title, message){        
        var toastEvent = $A.get("e.force:showToast");        
        toastEvent.setParams({
            "mode" : 'dismissible',
            "title": title,
            "message": message,
            "duration" : 8000,
            "type" : 'success'
        });
        toastEvent.fire();        
    },
})