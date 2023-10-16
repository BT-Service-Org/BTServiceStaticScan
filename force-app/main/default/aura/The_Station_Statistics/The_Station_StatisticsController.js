({
	doInit : function(cmp, event, helper) {
        console.log("on init");
        var newColor = cmp.get("v.backgroundColor");
        
        var titleSize = cmp.get("v.titleFontSize");
        if (titleSize >= 16 && titleSize <= 60) {
            cmp.set("v.intTitleFontSize", 'font-size: ' + titleSize + 'px;');
        } else {
            cmp.set("v.intTitleFontSize", 'font-size: ' + 42 + 'px;');
        }

        var titleAlign = cmp.get("v.titleAlignment");
        cmp.set("v.intTitleAlignment", 'text-align: ' + titleAlign + ';');

        var subtitleSize = cmp.get("v.subtitleFontSize");
        if (subtitleSize >= 20 && subtitleSize <= 34) {
            cmp.set("v.intSubtitleFontSize", 'font-size: ' + subtitleSize + 'px;');
        } else {
            cmp.set("v.intSubtitleFontSize", 'font-size: ' + 28 + 'px;');
        }

        var statSize = cmp.get("v.statFontSize");
        if (statSize >= 76 && statSize <= 120) {
            cmp.set("v.intStatFontSize", 'font-size: ' + statSize + 'px;');
        } else {
            cmp.set("v.intStatFontSize", 'font-size: ' + 92 + 'px;');
        }

        var statDetailSize = cmp.get("v.statDetailFontSize");
        if (statDetailSize >= 16 && statDetailSize <= 24) {
            cmp.set("v.intStatDetailFontSize", 'font-size: ' + statDetailSize + 'px;');
        } else {
            cmp.set("v.intStatDetailFontSize", 'font-size: ' + 22 + 'px;');
        }

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
        switch(newColor) {
            case "Light 1":
                $A.util.addClass(parent, 'backgroundColor-light1');
                $A.util.addClass(feedbackButton, 'buttonTheme-light1');
                break;
            case "Light 2":
                $A.util.addClass(parent, 'backgroundColor-light2');
                $A.util.addClass(feedbackButton, 'buttonTheme-light2');
                break;
            case "Dark 1":
                $A.util.addClass(parent, 'backgroundColor-dark1');
                $A.util.addClass(feedbackButton, 'buttonTheme-dark1');
                break;
            case "Dark 2":
                $A.util.addClass(parent, 'backgroundColor-dark2');
                $A.util.addClass(feedbackButton, 'buttonTheme-dark2');
                break;
        }
        
        var contentId = cmp.get("v.contentGroupId");
        var groupAction = cmp.get("c.getGroupName");
        groupAction.setParams({
            groupId : contentId
        });
        groupAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var group = response.getReturnValue();
                console.log(group);
                cmp.set("v.title", group.Name);
                cmp.set("v.subtitle", group.Group_Subtitle__c);
                var action = cmp.get("c.getGroups");
                action.setParams({
                    groupingList : contentId
                });
                action.setStorable();
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var records = response.getReturnValue();
                        records = records.slice(0,5);
                        cmp.set("v.groupList", records);
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(groupAction);
	},
    onFeedbackButtonFlow:function(cmp, event, helper) {                
        var cpID = event.currentTarget.getAttribute('data-cpID');
        var cpName = event.currentTarget.getAttribute('data-cpName');
        var cpOwner = event.currentTarget.getAttribute('data-cpOwner');
        var cpOwnerID = event.currentTarget.getAttribute('data-cpOwnerID');
        var cpPrimary = event.currentTarget.getAttribute('data-cpPrimary');
        var cpPrimaryID = event.currentTarget.getAttribute('data-cpPrimaryID');
        var orgInstanceUrl = event.currentTarget.getAttribute('data-orgInstanceUrl');
		console.log("onFeedbackButtonFlow click - origin url" + orgInstanceUrl);
		if($A.util.isEmpty(cpID)) {        
            helper.showToast(cmp,'error','ERROR','No Record ID Defined', 'dismiss');
        } else {
	        var modalBody;
    	    $A.createComponent("c:TheStation_SPRecordFeedbackFlow", 
				{
					cspRecordId: cpID,
					cspRecordOwnerID: cpOwnerID,
                    cspRecordPrimaryID: cpPrimaryID,
					cspRecordTitle: cpName,
                    orgInstanceUrl: orgInstanceUrl
				}, 
				function(content, status) {
					if (status === "SUCCESS") {
						modalBody = content;
						cmp.find('overlayLib').showCustomModal({
							header: "The Station - Submit Content Feedback",
							body: modalBody, 
							showCloseButton: true,
							cssClass: "modalBackgroundColor",
							closeCallback: function() {
								// DO NOTHING JUST CLOSE THE WINDOW                                
								// alert('You closed the alert!');
							}
						})
					}                               
				});
        }		        
    }
})