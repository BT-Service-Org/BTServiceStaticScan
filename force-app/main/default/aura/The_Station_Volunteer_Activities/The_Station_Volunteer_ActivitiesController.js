({
    doInit: function(cmp, event, helper) {
        
        var title = cmp.get("v.title");
        console.log("title: " + title);
        

        
    },

    recordsUpdated: function(cmp, evt) {
        var records = cmp.get("v.records");
        //console.log("records: " + records);

        records.forEach( record => {
            var epochSeconds = 0;
            epochSeconds = record.Shift_Start_Date_Time_sec_epoch;
            if (epochSeconds > 0) {
                var date = new Date(0);
                date.setUTCSeconds(epochSeconds);
                record.start_date = date;
                /*console.log("epochSeconds: " + epochSeconds);
                console.log("date: " + date);
                console.log("updated record: " + record);
                console.log("updated record date: " + record.start_date);*/
            }
        });

        // Limit display count to 6
        var limited = records.slice(0,6);
        cmp.set("v.privateRecords", limited);
    }
})