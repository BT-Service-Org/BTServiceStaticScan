({
    onShareSelect: function (cmp, event, helper) {
        
        var target = event.getSource();
        var name = target.get("v.collectionTitle");
        
        const eventValue = event.getParam('value').split(cmp.get('v.dataSeparator'));
        const command = eventValue[0];
        const contentUrl = eventValue[1];
        const contentTitle = eventValue[2];
        const groupcontentUrl = eventValue[3];
        switch (command) {
            case "Copy":
                var hiddenInput = document.createElement("input");
                hiddenInput.setAttribute("value", contentUrl);
                document.body.appendChild(hiddenInput);
                hiddenInput.select();
                document.execCommand("copy");
                document.body.removeChild(hiddenInput);
                helper.showShareToast("success", "URL copied!", "The URL has been copied to your clipboard successfully.");
                break;         
        }
    },   
    shareCollection: function (cmp, event, helper) {
        var target = event.getSource();
        var recordId = target.get("v.value");
        var collectionURL = "https://bedrockuat-dreamportal.cs8.force.com/thestation/s/station-pages/" + recordId;
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", collectionURL);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
        helper.showShareToast("success", "URL copied!", "The URL has been copied to your clipboard successfully.");

    }       
})