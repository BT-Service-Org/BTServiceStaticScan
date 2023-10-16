({
    CasesList: function(component) {
        var action = component.get('c.fetchCases');
        var recType = component.get('v.recType');
        var contentType = component.get('v.contentType');
        var togglecase = component.get('v.checked');
        var self = this;
        var originAction = component.get('c.getLexOriginUrl')
        var url = 'https://sfservices--bedrockuat.lightning.force.com';
        originAction.setCallback(this, function(result) {
            url = result.getReturnValue();
            //component.set("v.url", url + '/lightning/r/Case');
            component.set("v.url", url);

            console.log('origin url: ' + url);

            action.setParams({ 
                "recType" : recType,
                "contentType" : contentType,
                "togglecase" : togglecase
            });
            action.setCallback(this, function(actionResult) {
                component.set('v.cases', actionResult.getReturnValue());
            });
            $A.enqueueAction(action);
        })
        $A.enqueueAction(originAction);
    },
    siCaseList: function(component) {
        var action = component.get('c.fetchSICases');
        var originAction = component.get('c.getLexOriginUrl');
        var url = 'https://sfservices--bedrockuat.lightning.force.com';
        var togglecase = component.get('v.checked');
        originAction.setCallback(this, function(result) {
            url = result.getReturnValue();
            //component.set("v.url", url + '/lightning/r/Strategic_Initiative_c__x');
            component.set("v.url", url);
            
            action.setParams({ 
                "togglecase" : togglecase
            });

            action.setCallback(this, function(result) {
                //var cases = result.getReturnValue();
                component.set('v.cases', result.getReturnValue());
            });
            $A.enqueueAction(action);
        })
        $A.enqueueAction(originAction);
    },
    siAndRequestCaseList: function(component){
        //console.log("fetching both case types");
        var action = component.get('c.fetchSICases');
        var action2 = component.get('c.fetchCases');
        var sortaction = component.get('c.sortList');
        var originAction = component.get('c.getLexOriginUrl');
        var contentType = component.get('v.contentType');
        var url = 'https://sfservices--bedrockuat.lightning.force.com';
        var recType='The Station Content Request';
        var togglecase = component.get('v.checked');
        var cases=[];
        originAction.setCallback(this, function(result) {
            url = result.getReturnValue();
            //component.set("v.url", url + '/lightning/r/Strategic_Initiative_c__x');
            component.set("v.url", url);
            action.setParams({ 
                "togglecase" : togglecase
            });
            action.setCallback(this, function(result) {
                cases = cases.concat(result.getReturnValue());
                //console.log("cases......"+JSON.stringify(cases));
                //component.set('v.cases', result.getReturnValue());
                action2.setParams({ 
                    "recType" : recType,
                    "contentType" : contentType,
                    "togglecase" : togglecase
                });
                action2.setCallback(this, function(actionResult2) {
                    //component.set('v.cases', actionResult.getReturnValue());
                    //console.log("cases......"+JSON.stringify(actionResult2.getReturnValue()));
                    cases = cases.concat(actionResult2.getReturnValue());


                    sortaction.setParams({ 
                        "inputList" : cases
                    });
                    sortaction.setCallback(this, function(sortactionResult) {
                        //component.set('v.cases', actionResult.getReturnValue());
                        //console.log("cases......"+JSON.stringify(actionResult2.getReturnValue()));
                        cases = sortactionResult.getReturnValue();
                        
                        
    
                        component.set('v.cases', cases);
                        
                        //console.log("cases......"+JSON.stringify(cases));
                        
                    });
                    $A.enqueueAction(sortaction);

                    
                    //console.log("cases......"+JSON.stringify(cases));
                    
                });
                $A.enqueueAction(action2);

            });
            $A.enqueueAction(action);
        })
        $A.enqueueAction(originAction);
    }
})