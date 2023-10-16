({
    doEdit : function(id) {
        var windowHash = window.location.hash;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": id,
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;}
        });
        editRecordEvent.fire();
        
    },
})