({
    doInit : function(cmp, event, helper) {

    },
    onChange : function(cmp, event, helper) {
       var sortValue = cmp.find('sort').get('v.value');
       var sortEvent = cmp.getEvent("sortEvent");
        sortEvent.setParams({
            "sortType" : sortValue
         });

        sortEvent.fire();
    }

})