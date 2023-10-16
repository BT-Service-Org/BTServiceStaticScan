({
	doInit : function(cmp, event, helper) {
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
            groupId : contentId
        });
        nameAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                cmp.set("v.title", group.Name);
                var action = cmp.get("c.getGroups");
                helper.configureTheme(cmp);
                action.setParams({
                    groupingList : contentId
                });
                action.setStorable();
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        var limitOfRightRecords = cmp.get("v.leftColumnLimit")
                        cmp.set("v.applyGridLeftSide", "slds-col slds-size_1-of-1 slds-medium-size_12-of-12")
                        if(Number(records.length) > Number(limitOfRightRecords)){
                            cmp.set("v.applyGridLeftSide", "slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12")
                            cmp.set("v.showRightSide", true);
                        }

                        console.log('Test An : ' + records.length + "/" +limitOfRightRecords)

                        cmp.set("v.groupList", records);
                        helper.configureTheme(cmp);
                        var contentAction = cmp.get("c.getContentPieces");
                        contentAction.setParams({
                            contentJSON : JSON.stringify(records)
                        });
                        contentAction.setStorable();
                        contentAction.setCallback(this, function(contentResponse) {
                            if (state === "SUCCESS") {
                                var contentRecords = contentResponse.getReturnValue();
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
    } 
})