({
	calculateDetails : function(cmp) {
        var records = cmp.get("v.records");
        var maxHours = cmp.get("v.maxHours");

        var hoursCounter = 0;
        for (var i=0; i < records.length; i++) {
            var record = records[i];
            hoursCounter = hoursCounter + parseInt(record.Hours_Volunteered);
        }

        var hoursPercent = (hoursCounter / parseFloat(maxHours)) * 100.0;
        cmp.set("v.currentHoursTotal", hoursCounter);
        cmp.set("v.hoursPercent", hoursPercent);
    }
})