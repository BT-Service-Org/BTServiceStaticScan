({
	doInit: function(cmp, event, helper) {
		var apiTest = cmp.get("c.runApiTest");
        apiTest.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp);
                var datasets = "datasets/";
                var pos1 = resp.indexOf(datasets);
                pos1 = pos1 + datasets.length;
                var versions = "versions/";
                var pos2 = resp.indexOf(versions);
                //pos2 = pos2 + versions.length;
                if (pos1 > 0 && pos2 > 0) {
                    var sub = resp.substr(pos1, pos2);
                    sub = sub.replace(versions, '');
                    console.log('substring: ' + sub);
                    
                    var apiQuery = cmp.get("c.performQuery");
                    apiQuery.setParams({ datasetId : sub, employee : "Nicholas McDonald" });
                    apiQuery.setCallback(this, function(response) {
                        var resp = response.getReturnValue();
                        var respJson = JSON.stringify(resp);
                        cmp.set("v.jsonString", respJson);
                        console.log(resp);
                    });
                    $A.enqueueAction(apiQuery);
                }
            }
        });
        $A.enqueueAction(apiTest);
	}
})