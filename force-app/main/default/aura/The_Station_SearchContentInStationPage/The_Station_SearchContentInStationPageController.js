/*
Query 1 : select * from Station_Pages__c where Cloud_Product__c = 'CSG Career & Enablement' AND Content_Sub_Group_Name__c = 'Industries'

Query 2 : select * from Station_Pages__c where Cloud_Product__c = 'CSG Career & Enablement'

Community/Team (Community_Team__c) : Station website, CSG Enablement website, etc.
Product/Offering (Cloud_Product__c): This should only be used if the Community/Team= The Station Hub
Page (Content_Sub_Group_Name__c): Used if Community/Team ≠The Station Hub
*/
({
    doInit : function(cmp, event, helper) {
        var opts = [{ value: "Last Updated", label: "Last Updated" },
                    { value: "Created Date", label: "Created Date" },
                    { value: "Alphabetical", label: "Alphabetical", selected: true }];
            
        cmp.set('v.options', opts);
        cmp.set('v.selectedValue', 'Alphabetical');

        var a = cmp.get('c.doSort');
        $A.enqueueAction(a);

    },
    doSort : function(cmp, event, helper) {
        var collection = null;
        var action = null;
        var queryTerm = cmp.find('enter-search').get('v.value');
        var sType = cmp.get('v.selectedValue');
        var cTeam = cmp.get('v.stationCommunityTeam');
        var cProduct = cmp.get('v.stationCloudProduct');
        var sPage = cmp.get('v.stationPageName');
        action = cmp.get('c.searchContentInPage');    
        action.setParams({
            searchTerms : queryTerm,
            sortType : sType,
            communityTeam : cTeam,
            cloudProduct : cProduct,
            stationPage : sPage
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                collection = response.getReturnValue();
                cmp.set("v.groupList", collection);                  
                cmp.set("v.totalResults", collection ? collection.length : 0);
                if(queryTerm) {
                    cmp.set("v.searchTermValue", "'" + queryTerm + "'");                   
                    cmp.set("v.showSearchResults", true);
                } else {
                    cmp.set("v.searchTermValue", "All Records");                   
                    cmp.set("v.showSearchResults", false);
                }
                var userAction = cmp.get("c.getRunningUserInfo");
                userAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var user = response.getReturnValue();
                        cmp.set('v.runningUser',user);
                    }
                });
                $A.enqueueAction(userAction);

                var originAction = cmp.get("c.getLexOriginUrl");
                originAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var origin = response.getReturnValue();
                        cmp.set("v.originUrl", origin);
                    }
                });
                $A.enqueueAction(originAction);

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