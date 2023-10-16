({
    onFeedbackButtonFlow:function(cmp, event, helper) {   
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var eventCategory = userId + " : Button";        
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : eventCategory,
            eventAction : 'Give Feedback',
            eventLabel : event.target.name,
            eventValue: 1
        });
        analyticsInteraction.fire();

        var cpID = cmp.get("v.contentRecordId");
        var cpName = cmp.get("v.contentName");
        // OLD
        //        var cpOwnerID = cmp.get("v.contentOwnerId");
        var cpPrimaryID = cmp.get("v.contentPrimaryContactId");
        var orgInstanceUrl = cmp.get("v.contentOriginURL");
        var cType = cmp.get("v.contentType");
        var contentPieceId = cmp.get("v.contentPieceId");
        var cpOwnerID;

// NEW CODE
        var action = cmp.get("c.getFeedbackCaseLocalOwnerId");                
        action.setParams({ localStationContentID : cpID });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cpOwnerID = response.getReturnValue();
                cmp.set("v.contentOwnerId", cpOwnerID);
                
                console.log("onFeedbackButtonFlow\nType : " + cType + "\ncpID : " + cpID + "\ncontentPieceID : " + contentPieceId + "\ncpName : " + cpName + "\ncpOwnerID : " + cpOwnerID + "\ncpPrimaryID : " + cpPrimaryID + "\norgInstanceUrl : " + orgInstanceUrl);

                var modalBody;
                if (cType === "Success Program") {
                    $A.createComponent("c:TheStation_SI_FeedbackFlow", 
                    {
                        cspRecordId: contentPieceId,
                        cspRecordOwnerID: cpOwnerID,
                        cspRecordPrimaryID: cpPrimaryID,
                        cspRecordTitle: cpName,
                        orgInstanceUrl: orgInstanceUrl,

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
                } else {
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
        
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})