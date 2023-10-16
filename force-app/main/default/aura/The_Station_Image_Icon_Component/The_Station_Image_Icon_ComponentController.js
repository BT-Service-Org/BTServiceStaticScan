({
  doInit: function(cmp, event, helper) {
    var originAction = cmp.get("c.getLexOriginUrl");
    originAction.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var origin = response.getReturnValue();
            cmp.set("v.originUrl", origin);
        }
    });
    $A.enqueueAction(originAction);
    
    var nameAction = cmp.get("c.getGroupName");
    var contentId = cmp.get("v.recordId");
    nameAction.setParams({
        groupId : contentId
    });
    nameAction.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            var group = response.getReturnValue();
            cmp.set("v.title", group.Name);
            helper.configureTheme(cmp);
            var action = cmp.get("c.getGroups");
            action.setParams({
                groupingList : contentId
            });
            action.setStorable();
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var records = response.getReturnValue();
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
    onGiveFeedbackClick: function(cmp, event){
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'Give Feedback',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();
    },
    onFeedbackButtonFlow:function(cmp, event, helper) {                
        var cpID = event.currentTarget.getAttribute('data-cpID');
        var cpName = event.currentTarget.getAttribute('data-cpName');
        var cpOwner = event.currentTarget.getAttribute('data-cpOwner');
        var cpOwnerID = event.currentTarget.getAttribute('data-cpOwnerID');
        var cpPrimary = event.currentTarget.getAttribute('data-cpPrimary');
        var cpPrimaryID = event.currentTarget.getAttribute('data-cpPrimaryID');
        var orgInstanceUrl = event.currentTarget.getAttribute('data-orgInstanceUrl');
		if($A.util.isEmpty(cpID)) {        
            helper.showToast(cmp,'error','ERROR','No Success Program Record ID Defined', 'dismiss');
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
});