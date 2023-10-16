({
	doInit : function(cmp, event, helper) {
        var opts = [
            { value: "Most Popular", label: "Most Popular", selected: true },
            { value: "Last Updated", label: "Last Updated" },
            { value: "Created Date", label: "Created Date" },
            { value: "Alphabetical", label: "Alphabetical" }];
            
        cmp.set('v.options', opts);
        cmp.set('v.selectedValue', 'Most Popular');
        cmp.set('v.showFollowCollection', false);

        var a = cmp.get('c.doSort');
        $A.enqueueAction(a);

    },
    doSort : function(cmp, event, helper) {
        var filter = cmp.get("v.collectionFilter");
        var sort = cmp.find("collectionSort").get("v.value");
        var sortT = cmp.get('v.selectedValue');
        var collection = null;
        var action = null;
        var queryTerm = cmp.find('enter-search').get('v.value');
        action = cmp.get("c.searchPublicCollections");                
        action.setParams({
            searchTerms : queryTerm,
            sortType :  cmp.get('v.selectedValue')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                collection = response.getReturnValue();
                cmp.set("v.collectionList", collection);                       
                cmp.set("v.totalResults", collection ? collection.length : 0);
                if(queryTerm) {
                    cmp.set("v.searchTermValue", "'" + queryTerm + "'");                   
                } else {
                    cmp.set("v.searchTermValue", "All Records");                   
                }                    
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);     
    },
    handleKeyUp: function (cmp, evt) {
        var collection = null;
        var action = null;
        var isEnterKey = evt.keyCode === 13;
//        var queryTerm = cmp.find('enter-search').get('v.value');
        if (isEnterKey) {
            cmp.set('v.issearching', true);
            var a = cmp.get('c.doSort');
            $A.enqueueAction(a);
            cmp.set('v.issearching', false);
        }
    },    
    onchangeSearch: function (cmp, evt) {
        var queryTerm = cmp.find('enter-search').get('v.value');
        if (queryTerm == '') {
            cmp.set('v.issearching', true);
            var a = cmp.get('c.doSort');
            $A.enqueueAction(a);
            cmp.set('v.issearching', false);
        }
    },
})