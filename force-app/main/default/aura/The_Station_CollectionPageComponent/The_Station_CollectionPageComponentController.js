({
    doInit : function(cmp, event, helper) {

    },
    handleComponentEvent : function(cmp, event, helper) {
        var sortType = event.getParam("sortType");
        cmp.set("v.selectedSort",sortType);
    }
})