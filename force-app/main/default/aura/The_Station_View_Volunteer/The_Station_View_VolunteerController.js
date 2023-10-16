({
	doInit: function(cmp, event, helper) {

        // FOR DEPLOYMENT
        // COMMENT FROM HERE
        /*
        var json = {"records":[
            {"Activity_Type":"Board Service","EMP_NAME":"Test Name","Hours_Volunteered":"1","Shift_Start_Date_Time_sec_epoch":"1444867000"},
            {"Activity_Type":"Equality Groups","EMP_NAME":"Test Name","Hours_Volunteered":"1","Shift_Start_Date_Time_sec_epoch":"1444867100"},
            {"Activity_Type":"Fundraising Campaign","EMP_NAME":"Test Name","Hours_Volunteered":"4","Shift_Start_Date_Time_sec_epoch":"1444867200"},
            {"Activity_Type":"Mentoring","EMP_NAME":"Test Name","Hours_Volunteered":"1","Shift_Start_Date_Time_sec_epoch":"1457568000"},
            {"Activity_Type":"Hands-on Activity","EMP_NAME":"Test Name","Hours_Volunteered":"3","Shift_Start_Date_Time_sec_epoch":"1484956800"},
            {"Activity_Type":"Hands-on Activity","EMP_NAME":"Test Name","Hours_Volunteered":"4","Shift_Start_Date_Time_sec_epoch":"1492905600"},
            {"Activity_Type":"Pro Bono","EMP_NAME":"Test Name","Hours_Volunteered":"2","Shift_Start_Date_Time_sec_epoch":"1444867600"},
            {"Activity_Type":"Walk/Run/Ride/Swim","EMP_NAME":"Test Name","Hours_Volunteered":"1","Shift_Start_Date_Time_sec_epoch":"1444868200"},
        ]};

        //Shift_Start_Date_Time_Day
        //Shift_Start_Date_Time_sec_epoch

        cmp.set("v.records", json.records);
        if(json.records==null){  
        	cmp.set("v.noDataToDisplay", true);
        }
        helper.calculateDetails(cmp);

        return;
        */
        // COMMENT TO HERE
        // FOR DEPLOYMENT

		var apiTest = cmp.get("c.getCurrentVersion");
        apiTest.setCallback(this, function(response) {
            var state = response.getState();
            console.log('getCurrentVersion>state: '+state);
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
                    apiQuery.setParams({ datasetId : sub});
                    apiQuery.setCallback(this, function(response) {
                        var resp = response.getReturnValue();
                        var respJson = JSON.stringify(resp);
                        cmp.set("v.records", resp.records);
                        if(resp.records==null){  
                            cmp.set("v.noDataToDisplay", true);
                        }
                        helper.calculateDetails(cmp);
                        console.log('View Volunteer > records: '+resp.records);
                        console.log(typeof(resp.records));
                    });
                    $A.enqueueAction(apiQuery);
                }
            }
        });
        $A.enqueueAction(apiTest);
	}
})