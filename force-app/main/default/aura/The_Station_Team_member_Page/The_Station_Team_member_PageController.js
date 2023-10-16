({
    doInit: function (cmp, event, helper) {
        var titleSize = cmp.get("v.titleFontSize");
        if (titleSize >= 16 && titleSize <= 60) {
            cmp.set("v.intTitleFontSize", 'font-size: ' + titleSize + 'px;');
        } else {
            cmp.set("v.intTitleFontSize", 'font-size: ' + 42 + 'px;');
        }

        var numMemberColumns = cmp.get("v.numMemberColumns");
        if (numMemberColumns >= 4) {
            cmp.set("v.containerHorizPadding", '0px;');
        } else {
            cmp.set("v.containerHorizPadding", '10px;');
        }


        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');
        var newColor = cmp.get("v.backgroundColor");

        var parent = cmp.find("parent");
        var feedbackButton = cmp.find("feedback-button");

        $A.util.removeClass(parent, 'backgroundColor-light1');
        $A.util.removeClass(parent, 'backgroundColor-light2');
        $A.util.removeClass(parent, 'backgroundColor-dark1');
        $A.util.removeClass(parent, 'backgroundColor-dark2');
        $A.util.removeClass(feedbackButton, 'buttonTheme-light1');
        $A.util.removeClass(feedbackButton, 'buttonTheme-light2');
        $A.util.removeClass(feedbackButton, 'buttonTheme-dark1');
        $A.util.removeClass(feedbackButton, 'buttonTheme-dark2');
        switch (newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                $A.util.addClass(feedbackButton, 'buttonTheme-light1');
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                $A.util.addClass(feedbackButton, 'buttonTheme-light2');
                cmp.set("v.hrefColorStyle", 'color: #0070D2')
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                $A.util.addClass(feedbackButton, 'buttonTheme-dark1');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                $A.util.addClass(feedbackButton, 'buttonTheme-dark2');
                cmp.set("v.hrefColorStyle", 'color: #FFFFFF')
                break;
        }



        if (cmp.get("v.numMemberColumns") == 5) {
            cmp.set("v.memberColumnstyle", 'slds-col slds-size_1-of-5');
        } else {
            var strMemberColumnSpacing = (12 / cmp.get("v.numMemberColumns")).toString();
            var strMemberColumnStyle = 'slds-col slds-size_' + strMemberColumnSpacing + '-of-12';
            cmp.set("v.memberColumnstyle", strMemberColumnStyle);
        }

        if (cmp.get("v.numLeaderColumns") == 5) {
            cmp.set("v.leaderColumnstyle", 'slds-col slds-size_1-of-5');
        } else {
            var strLeaderColumnSpacing = (12 / cmp.get("v.numLeaderColumns")).toString();
            var strLeaderColumnStyle = 'slds-col slds-size_' + strLeaderColumnSpacing + '-of-12';
            cmp.set("v.leaderColumnstyle", strLeaderColumnStyle);
        }

        $A.util.removeClass(parent, 'full-width');
        if (cmp.get("v.isFullScreenWidth")) {
            $A.util.addClass(parent, 'full-width');
        }

        var contentId = cmp.get("v.recordId");
        var groupAction = cmp.get("c.getGroupName");
        groupAction.setParams({
            groupId: contentId
        });
        groupAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                cmp.set("v.title", group.Name);

                // get member details
                var action1 = cmp.get("c.getMemberDetails");
                action1.setParams({
                    recordId: contentId,
                    numLeader: cmp.get("v.numLeader")
                });
                action1.setCallback(this, function (data1) {
                    var state1 = data1.getState();

                    //check if result is successfull
                    if (state1 == "SUCCESS") {
                        //Perform Action after the result
                        // console.log("Success in calling server side action");
                        cmp.set("v.stationMemberRecord", data1.getReturnValue());
                        //console.log(data1.getReturnValue());
                    } else if (state1 == "ERROR") {
                        console.log("Error in calling server side action");
                    }
                });
                $A.enqueueAction(action1);

                var action2 = cmp.get("c.getLeaderDetails");
                action2.setParams({
                    recordId: cmp.get("v.recordId"),
                    numLeader: cmp.get("v.numLeader")
                });
                action2.setCallback(this, function (data2) {

                    var state2 = data2.getState();

                    //check if result is successfull
                    if (state2 == "SUCCESS") {
                        //Perform Action after the result
                        //console.log("Success in calling server side action");
                        cmp.set("v.stationLeaderRecord", data2.getReturnValue());
                        // console.log(data2.getReturnValue());
                    } else if (state2 == "ERROR") {
                        console.log("Error in calling server side action");
                    }
                });
                $A.enqueueAction(action2);
            }
        });
        $A.enqueueAction(groupAction);
    }
});