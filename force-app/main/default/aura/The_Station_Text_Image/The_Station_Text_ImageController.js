({
    doInit: function (cmp, event, helper) {

        //getRunningUserInfo
        var userAction = cmp.get("c.getRunningUserInfo");
        userAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue();
                cmp.set('v.runningUser', user);
            }
        });
        $A.enqueueAction(userAction);


        //getLexOriginUrl
        var originAction = cmp.get("c.getLexOriginUrl");
        originAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var origin = response.getReturnValue();
                cmp.set("v.originUrl", origin);
            }
        });
        $A.enqueueAction(originAction);


        //getGroupName
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
                helper.configureTheme(cmp);
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
                                var contentRecords = contentResponse.getReturnValue();

                                // For each element, calculate if its a fresh content based on creation date and last modification date
                                // Forced to calculate it here in the contrller due to date parsing limitations in the view
                                var twoWeeksBeforeDate = new Date(Date.now() - 12096e5);
                                for (var key in contentRecords) {
                                    if (contentRecords.hasOwnProperty(key)) {

                                        var createdDate = new Date(contentRecords[key].content.CreatedDate);
                                        var LastModifiedDate = new Date(contentRecords[key].content.LastModifiedDate);
                                        var freshContent = (createdDate > twoWeeksBeforeDate || LastModifiedDate > twoWeeksBeforeDate);

                                        contentRecords[key].content.freshContent = freshContent;
                                    }
                                }

                                cmp.set("v.groupList", contentRecords);
                                helper.configureTheme(cmp);
                                cmp.set("v.isLoading", false);
                            } else {
                                cmp.set("v.isLoading", false);
                            }
                        });
                        $A.enqueueAction(contentAction);
                    } else {
                        cmp.set("v.isLoading", false);
                    }
                });

                $A.enqueueAction(action);

            } else {
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(nameAction);
    },

    onAdditionalLinkClick: function (cmp, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";

        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType: 'event',
            eventCategory: eventCategory,
            eventAction: 'Additional URL',
            eventLabel: event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    }
})