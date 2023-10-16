({
    doInit: function (cmp, event, helper) {

        var userAction = cmp.get("c.getRunningUserInfo");
        userAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue();
                cmp.set('v.runningUser',user);
            }
        });
        $A.enqueueAction(userAction);

        var originAction = cmp.get("c.getLexOriginUrl");
        originAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var origin = response.getReturnValue();
                cmp.set("v.originUrl", origin);
            }
        });
        $A.enqueueAction(originAction);

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
                                cmp.set("v.groupList", contentRecords);
                                helper.configureTheme(cmp);
                            }
                        });
                        $A.enqueueAction(contentAction);
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(nameAction);
    },

    onFeedbackButtonFlow: function (cmp, event, helper) {
    }
})