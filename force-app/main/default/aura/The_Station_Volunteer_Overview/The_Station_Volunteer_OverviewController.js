({
    doInit: function(cmp, event, helper) {

    },
    scriptsLoaded : function(cmp, event, helper) {
        helper.drawChart(cmp);
    },
    recordsUpdated: function(cmp, event, helper) {
        helper.drawChart(cmp);
    }
})