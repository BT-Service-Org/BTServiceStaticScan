({
    doInit: function (cmp, event, helper) {
        cmp.set("v.globalId", cmp.getGlobalId().replace(/[;:-]/g,""));
        // FETCH CONTENT
        var contentId = cmp.get("v.contentGroupId");
        var nameAction = cmp.get("c.getGroupName");
        nameAction.setParams({
            groupId: contentId
        });
        nameAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                cmp.set("v.title", group.Name);
                cmp.set("v.subTitle", group.Group_Subtitle__c);

                var action = cmp.get("c.getGroups");
                action.setParams({
                    groupingList: contentId
                });
                action.setStorable();
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        cmp.set("v.groupList", records);
                        helper.configureTheme(cmp);
                        var contentAction = cmp.get("c.getContentPieces");
                        contentAction.setParams({
                            contentJSON: JSON.stringify(records)
                        });
                        contentAction.setStorable();
                        contentAction.setCallback(this, function (contentResponse) {
                            if (state === "SUCCESS") {
                                helper.initSlick(cmp);
                                var contentRecords = contentResponse.getReturnValue();

                                // For each element, calculate if its a fresh content based on creation date and last modification date
                                // Forced to calculate it here in the contrller due to date parsing limitations in the view
                                var twoWeeksBeforeDate = new Date(Date.now() - 12096e5);
                                for (var key in contentRecords) {
                                    if (contentRecords.hasOwnProperty(key)) {

                                        var createdDate = new Date(contentRecords[key].content.CreatedDate);
                                        var LastModifiedDate = new Date(contentRecords[key].content.LastModifiedDate);
                                        var freshContent = ( createdDate > twoWeeksBeforeDate || LastModifiedDate > twoWeeksBeforeDate );

                                        contentRecords[key].content.freshContent = freshContent;
                                    }
                                }

                                cmp.set("v.groupList", contentRecords);
                                helper.configureTheme(cmp);
                                cmp.set("v.isLoading",false);
                            }else{
                                cmp.set("v.isLoading",false);
                            }
                        });
                        $A.enqueueAction(contentAction);
                    }else{
                        cmp.set("v.isLoading",false);
                    }
                });
                $A.enqueueAction(action);
            }else{
                cmp.set("v.isLoading",false);
            }
        });
        $A.enqueueAction(nameAction);
    },
    afterLoad: function (cmp, event, helper) {
        cmp.set("v.areLibrariesLoaded", true);
    },

    onShareSelect: function (cmp, event, helper) {
        const eventValue = event.getParam('value').split(cmp.get('v.dataSeparator'));
        const command = eventValue[0];
        const contentUrl = eventValue[1];
        const contentTitle = eventValue[2];
        switch (command) {
            case "Copy":
                var hiddenInput = document.createElement("input");
                hiddenInput.setAttribute("value", contentUrl);
                document.body.appendChild(hiddenInput);
                hiddenInput.select();
                document.execCommand("copy");
                document.body.removeChild(hiddenInput);
                helper.showToast("success", "URL copied!", "The URL has been copied to your clipboard successfully.");
                break;
            case "Email":
                cmp.set("v.emailSubject", "Helpful Content");
                cmp.set("v.emailBody", "Check out this piece of content I found on The Station: <a href='" + contentUrl + "'>" + contentTitle + "</a>. <br> Thank you for your support. <br> -The Station Team");
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