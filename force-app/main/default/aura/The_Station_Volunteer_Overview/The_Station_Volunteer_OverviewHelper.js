({
    drawChart : function(cmp) {
        var records = cmp.get("v.records");
        console.log('Volunteer Overview > records: '+records);
        if (records == null) {
            return;
        }

        var typesContainer = [];
        // example
        // [{type:Board Service, count:12},{type:Equality Groups, count:1}]

        for (var i=0; i < records.length; i++) {
            var record = records[i];
            var activity = record.Activity_Type;
            var hours = parseInt(record.Hours_Volunteered);
            
	        console.log('Vounteer Overview > record: '+record);

            var found = false;
            for (var j=0; j < typesContainer.length; j++) {
                var value = typesContainer[j];
                var type = value.type;
                if (type === activity) {
                    found = true;
                    console.log("found " + activity + " adding " + hours + " hours");
                    console.log("hours before add: " + typesContainer[j]['hours']);
                    typesContainer[j]['hours'] = hours + parseInt(typesContainer[j]['hours']);
                    console.log("hours after add: " + typesContainer[j]['hours']);
                }
            }

            if (!found) {
                console.log('not found, adding : ' + activity + ' with ' + hours + ' hours');
                typesContainer.push({'type':activity, 'hours':hours});
            }

            console.log('current typesContainer: ' + typesContainer);
        }

        var labelset=[] ;
        var dataset=[];

        for (var j=0; j < typesContainer.length; j++) {
            var activity = typesContainer[j]['type'];
            var hours = typesContainer[j]['hours'];
            labelset.push(activity);
            dataset.push(parseInt(hours));
        }

        new Chart(document.getElementById("pie-chart"), {
            type: 'doughnut',
            options: {
                legend: {
                    display: false,
                    position: 'bottom',
                    labels: {
                        boxWidth: 8,
                        fontSize: 8
                    }
                },
                cutoutPercentage: 65,
                responsive: true
            },
            data: {
                labels:labelset,
                datasets: [{
                    label: "Count of Task",
                    backgroundColor: ["#52B7D8", "#E16032","#FFB03B","#54A77B", "#4FD2D2","#E287B2","#A3A3A3","#F6516D"],
                    data: dataset
                }]
            },
        });
    }
})