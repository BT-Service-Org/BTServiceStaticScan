({
    doInit : function(cmp, event, helper) {
        var paramString = window.location.href;
        var originurlAction = cmp.get("c.getUrlSubstring");
        originurlAction.setParams({
            Url : paramString
        });
        originurlAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnString = response.getReturnValue();
                if (returnString!=null){
                var totalUrl = returnString;
                }
                else {
                var totalUrl = "";
                }
                 cmp.set("v.urlExtension", totalUrl);
            }
        });
        $A.enqueueAction(originurlAction); 

        var urlAction = cmp.get("c.getLexOriginUrl");
        urlAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var baseUrl = response.getReturnValue();
                cmp.set("v.baseUrl",baseUrl);
            }
        });
        $A.enqueueAction(urlAction); 

    },
        onShareSelect: function (cmp, event, helper) {
        var target = event.getSource();
        var name = target.get("v.contentpiece.content.Name");
        var user = cmp.get("v.runningUser");
        var userId = user.Id;
        var eventCategory = userId + " : Button";
        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");

        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Share Content',
            eventLabel : name,
            eventValue: 1
        });

        analyticsInteraction.fire();
        
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
            case "Email":
                cmp.set("v.emailSubject", "Helpful Content");
                cmp.set("v.emailBody", "Check out this piece of content I found on The Station: <a href='" + contentUrl + "'>" + contentTitle + "</a>. <br>Click here to see other content relevant to "+contentTitle+":<a href='"+groupcontentUrl+"'>More Content </a><br>Thank you for your support. <br>-The Station Team");
                helper.showSendEmailPopup(cmp);
                break;
        }
    },
    onSendClick: function (cmp, event, helper) {
    
            var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        
            if (allValid) {
                var action = cmp.get("c.sendMailMethod");
                action.setParams({
                    'mMail': cmp.get("v.emailRecipient"),
                    'mSubject': cmp.get("v.emailSubject"),
                    'mbody': cmp.get("v.emailBody")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        helper.showToast("success", "Email sent", "The Email has been sent successfully.");
                    }
                    else if (state === "ERROR") {
                        helper.showToast("error", "Email not sent", "Unexpected technical error when sending the email. Please contact the admin.");
                    }
                });
                $A.enqueueAction(action);
                helper.resetEmailAttributes(cmp);
                helper.hideSendEmailPopup(cmp);
            }
        },
        onCancelClick: function (cmp, event, helper) {
            helper.resetEmailAttributes(cmp);
            helper.hideSendEmailPopup(cmp);
        }
})